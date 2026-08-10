# import os
# import pandas as pd
# import re
# from cz_dbconnection import run_query
# from cz_screenshot_util import capture_screenshot
# from cz_constants import SCREENSHOT_DIR, REPORT_DIR,DNA_STAGE_SCHEMA

# REPORT_DIR = "reports"
# os.makedirs(SCREENSHOT_DIR, exist_ok=True)
# os.makedirs(REPORT_DIR, exist_ok=True)


# def normalize_data_type(dt: str) -> str:
#     if not isinstance(dt, str):
#         return ""
#     dt = dt.strip().lower()
#     match = re.match(r"([a-z ]+)", dt)
#     base_type = match.group(1).strip() if match else dt
#     if base_type in ['varchar', 'char', 'string', 'character', 'character varying']:
#         return 'character varying'
#     if base_type in ['timestamp without time zone', 'timestamp', 'timestmp']:
#         return 'timestamp without time zone'
#     if base_type in ['int', 'integer', 'bigint', 'smallint']:
#         return 'integer'
#     if base_type in ['numeric']:
#         return 'decimal'
#     return base_type


# def extract_length(data_type_str) -> str:
#     """Pull the raw length/precision text out of a data type string,
#     e.g. varchar(50) -> '50', numeric(9,2) -> '9,2'."""
#     if not isinstance(data_type_str, str):
#         return ''
#     if '(' in data_type_str and ')' in data_type_str:
#         return data_type_str[data_type_str.find('(')+1:data_type_str.find(')')].strip()
#     return ''


# def normalize_length(length_str) -> str:
#     """Keep only the precision/length part (drop any scale after a comma),
#     e.g. '9,2' -> '9'. Safe to call on already-plain values like '50'."""
#     if not isinstance(length_str, str) or length_str == '':
#         return ''
#     return length_str.split(',')[0].strip()

# def run_structure_validation(app, update_treeview=None):
#     steps = []

#     # Pre-checks
#     if not hasattr(app, "loaded_sheets") or not hasattr(app, "stage_table_name"):
#         steps.append({
#             "step_no": 0,
#             "step_name": "Pre-check",
#             "description": "Excel file not loaded or stage table name missing.",
#             "status": "WARNING",
#             "screenshot": None,
#             "validation_name": "Structure Validation",
#             "test_case_description": "Validate the Structure/Schema of Redshift Stage Table"
#         })
#         if update_treeview:
#             update_treeview("Structure Validation", pd.DataFrame(steps).drop(columns=["test_case_description"], errors="ignore"))
#         return steps

#     stage_df = app.loaded_sheets.get('stage_table_mapping')
#     stage_table_name = app.stage_table_name

#     if stage_df is None or not stage_table_name:
#         steps.append({
#             "step_no": 0,
#             "step_name": "Spec Check",
#             "description": "Redshift Staging Target sheet or table name missing.",
#             "status": "WARNING",
#             "screenshot": None,
#             "validation_name": "Structure Validation",
#             "test_case_description": "Validate the Structure/Schema of Redshift Stage Table"
#         })
#         if update_treeview:
#             update_treeview("Structure Validation", pd.DataFrame(steps).drop(columns=["test_case_description"], errors="ignore"))
#         return steps

#     # Ensure required columns exist after renaming in excel_loader
#     for col in ['column_name', 'data_type']:
#         if col not in stage_df.columns:
#             steps.append({
#                 "step_no": 0,
#                 "step_name": "Sheet Format Check",
#                 "description": f"Redshift Staging Target sheet missing required column: '{col}'. "
#                                f"Available: {list(stage_df.columns)}",
#                 "status": "WARNING",
#                 "screenshot": None,
#                 "validation_name": "Structure Validation",
#                 "test_case_description": "Validate the Structure/Schema of Redshift Stage Table"
#             })
#             if update_treeview:
#                 update_treeview("Structure Validation", pd.DataFrame(steps).drop(columns=["test_case_description"], errors="ignore"))
#             return steps

#     # Build expected df: column_name + data_type (+ length, captured before the
#     # data type string is stripped of its parentheses so we can compare lengths too)
#     expected_df = stage_df[['column_name', 'data_type']].copy()
#     expected_df = expected_df[
#         expected_df['column_name'].notna() &
#         (expected_df['column_name'].astype(str).str.strip() != '')
#     ].reset_index(drop=True)

#     expected_df['column_name'] = (
#         expected_df['column_name'].astype(str).str.strip().str.lower()
#     )
#     raw_expected_type = expected_df['data_type'].fillna('').astype(str).str.strip().str.lower()
#     expected_df['expected_length'] = raw_expected_type.apply(extract_length).apply(normalize_length)
#     expected_df['data_type'] = (
#         raw_expected_type
#         .str.replace(r"\(.*\)", "", regex=True)
#         .str.strip()
#         .apply(normalize_data_type)
#     )

#     # Query actual DB schema — col_length is computed directly in SQL so we
#     # get one comparable string whether the column is character-based
#     # (character_maximum_length) or numeric (numeric_precision).
#     structure_query = f"""
#     SELECT
#       column_name,
#       data_type,
#       CASE
#         WHEN character_maximum_length IS NULL THEN COALESCE(numeric_precision::text, '')
#         ELSE COALESCE(character_maximum_length::text, '')
#       END AS col_length
#     FROM pg_catalog.svv_all_columns
#     WHERE schema_name = '{DNA_STAGE_SCHEMA}'
#       AND table_name  = '{stage_table_name}'
#     ORDER BY ordinal_position;
#     """

#     try:
#         actual_df = run_query(structure_query)
#     except Exception as e:
#         steps.append({
#             "step_no": 1,
#             "step_name": "DB Structure Query",
#             "description": f"SQL Execution Failed: {e}",
#             "status": "WARNING",
#             "screenshot": None,
#             "validation_name": "Structure Validation",
#             "test_case_description": "Validate the Structure/Schema of Redshift Stage Table",
#             "sql_query": structure_query,
#         })
#         if update_treeview:
#             update_treeview("Structure Validation", pd.DataFrame(steps).drop(columns=["test_case_description"], errors="ignore"))
#         return steps

#     if actual_df is None or actual_df.empty:
#         steps.append({
#             "step_no": 1,
#             "step_name": "DB Structure Query",
#             "description": f"No columns found for {DNA_STAGE_SCHEMA}.{stage_table_name}.",
#             "status": "WARNING",
#             "screenshot": None,
#             "validation_name": "Structure Validation",
#             "test_case_description": "Validate the Structure/Schema of Redshift Stage Table",
#             "sql_query": structure_query,
#         })
#         if update_treeview:
#             update_treeview("Structure Validation", pd.DataFrame(steps).drop(columns=["test_case_description"], errors="ignore"))
#         return steps

#     actual_df['column_name'] = actual_df['column_name'].astype(str).str.strip().str.lower()
#     actual_df['data_type']   = actual_df['data_type'].fillna('').astype(str).apply(normalize_data_type)
#     actual_df['col_length']  = actual_df['col_length'].fillna('').astype(str).apply(normalize_length)

#     # Merge and compare (name, data type, AND column length)
#     merged = pd.merge(
#         expected_df,
#         actual_df[['column_name', 'data_type', 'col_length']].rename(
#             columns={'data_type': 'actual_data_type', 'col_length': 'actual_length'}
#         ),
#         on='column_name',
#         how='left'
#     )

#     results = []
#     for _, row in merged.iterrows():
#         exp_len = row.get('expected_length', '')
#         act_dt = row.get('actual_data_type', '')
#         act_len = row.get('actual_length', '')

#         if pd.isna(act_dt) or act_dt == '':
#             status = "Missing in DB"
#         else:
#             mismatches = []
#             if row['data_type'] != act_dt:
#                 mismatches.append("Datatype mismatch")
#             if exp_len and exp_len != act_len:
#                 mismatches.append("Length mismatch")
#             status = "PASS" if not mismatches else "; ".join(mismatches)

#         results.append({
#             "Column Name":        row['column_name'],
#             "Expected Data Type": row['data_type'],
#             "Actual Data Type":   act_dt,
#             "Expected Length":    exp_len,
#             "Actual Length":      act_len,
#             "Status":             status,
#         })

#     # Extra columns in DB not in spec
#     spec_cols = set(expected_df['column_name'])
#     for _, row in actual_df.iterrows():
#         if row['column_name'] not in spec_cols:
#             results.append({
#                 "Column Name":        row['column_name'],
#                 "Expected Data Type": "",
#                 "Actual Data Type":   row['data_type'],
#                 "Expected Length":    "",
#                 "Actual Length":      row.get('col_length', ''),
#                 "Status":             "Missing in ETL Spec",
#             })

#     results_df = pd.DataFrame(results)

#     etl_shot = capture_screenshot(expected_df, "etl_structure")
#     db_shot   = capture_screenshot(actual_df,   "db_structure")
#     cmp_shot  = capture_screenshot(results_df,  "structure_comparison", status_column="Status")

#     final_status = "PASS" if (results_df['Status'] == 'PASS').all() else "FAIL"

#     steps.extend([
#         {
#             "step_no": 1,
#             "step_name": "ETL Spec Structure",
#             "description": "Capture column names, data types, and expected lengths from Redshift Staging Target sheet.",
#             "status": "PASS",
#             "screenshot": etl_shot,
#             "validation_name": "Structure Validation",
#             "test_case_description": "Validate the Structure/Schema of Redshift Stage Table"
#         },
#         {
#             "step_no": 2,
#             "step_name": "DB Table Structure",
#             "description": f"Capture column names, data types, and column lengths from {DNA_STAGE_SCHEMA} table.",
#             "status": "PASS",
#             "screenshot": db_shot,
#             "validation_name": "Structure Validation",
#             "sql_query": structure_query,
#         },
#         {
#             "step_no": 3,
#             "step_name": "Comparison",
#             "description": "Compare column names, data types, and column lengths between ETL spec and DB.",
#             "status": final_status,
#             "screenshot": cmp_shot,
#             "validation_name": "Structure Validation",
#             "sql_query": structure_query,
#         }
#     ])

#     if update_treeview:
#         update_treeview(
#             "Structure Validation",
#             pd.DataFrame(steps).drop(columns=["test_case_description"], errors="ignore")
#         )

#     return steps




import os
import pandas as pd
import re
from cz_dbconnection import run_query
from cz_screenshot_util import capture_screenshot
from cz_constants import SCREENSHOT_DIR, REPORT_DIR,DNA_STAGE_SCHEMA

REPORT_DIR = "reports"
os.makedirs(SCREENSHOT_DIR, exist_ok=True)
os.makedirs(REPORT_DIR, exist_ok=True)


def normalize_data_type(dt: str) -> str:
    if not isinstance(dt, str):
        return ""
    dt = dt.strip().lower()
    match = re.match(r"([a-z ]+)", dt)
    base_type = match.group(1).strip() if match else dt
    if base_type in ['varchar', 'char', 'string', 'character', 'character varying']:
        return 'character varying'
    if base_type in ['timestamp without time zone', 'timestamp', 'timestmp']:
        return 'timestamp without time zone'
    if base_type in ['int', 'integer', 'bigint', 'smallint']:
        return 'integer'
    if base_type in ['numeric','decimal','dec']:
        return 'decimal'
    return base_type


def extract_length(data_type_str) -> str:
    """Pull the raw length/precision text out of a data type string,
    e.g. varchar(50) -> '50', numeric(9,2) -> '9,2'."""
    if not isinstance(data_type_str, str):
        return ''
    if '(' in data_type_str and ')' in data_type_str:
        return data_type_str[data_type_str.find('(')+1:data_type_str.find(')')].strip()
    return ''


def normalize_length(length_str) -> str:
    """Keep only the precision/length part (drop any scale after a comma),
    e.g. '9,2' -> '9'. Safe to call on already-plain values like '50'."""
    if not isinstance(length_str, str) or length_str == '':
        return ''
    return length_str.split(',')[0].strip()

def run_structure_validation(app, update_treeview=None):
    steps = []

    # Pre-checks
    if not hasattr(app, "loaded_sheets") or not hasattr(app, "stage_table_name"):
        steps.append({
            "step_no": 0,
            "step_name": "Pre-check",
            "description": "Excel file not loaded or stage table name missing.",
            "status": "WARNING",
            "screenshot": None,
            "validation_name": "Structure Validation",
            "test_case_description": "Validate the Structure/Schema of Redshift Stage Table"
        })
        if update_treeview:
            update_treeview("Structure Validation", pd.DataFrame(steps).drop(columns=["test_case_description"], errors="ignore"))
        return steps

    stage_df = app.loaded_sheets.get('stage_table_mapping')
    stage_table_name = app.stage_table_name

    if stage_df is None or not stage_table_name:
        steps.append({
            "step_no": 0,
            "step_name": "Spec Check",
            "description": "Redshift Staging Target sheet or table name missing.",
            "status": "WARNING",
            "screenshot": None,
            "validation_name": "Structure Validation",
            "test_case_description": "Validate the Structure/Schema of Redshift Stage Table"
        })
        if update_treeview:
            update_treeview("Structure Validation", pd.DataFrame(steps).drop(columns=["test_case_description"], errors="ignore"))
        return steps

    # Ensure required columns exist after renaming in excel_loader
    for col in ['column_name', 'data_type']:
        if col not in stage_df.columns:
            steps.append({
                "step_no": 0,
                "step_name": "Sheet Format Check",
                "description": f"Redshift Staging Target sheet missing required column: '{col}'. "
                               f"Available: {list(stage_df.columns)}",
                "status": "WARNING",
                "screenshot": None,
                "validation_name": "Structure Validation",
                "test_case_description": "Validate the Structure/Schema of Redshift Stage Table"
            })
            if update_treeview:
                update_treeview("Structure Validation", pd.DataFrame(steps).drop(columns=["test_case_description"], errors="ignore"))
            return steps

    # Build expected df: column_name + data_type (+ length, captured before the
    # data type string is stripped of its parentheses so we can compare lengths too)
    expected_df = stage_df[['column_name', 'data_type']].copy()
    expected_df = expected_df[
        expected_df['column_name'].notna() &
        (expected_df['column_name'].astype(str).str.strip() != '')
    ].reset_index(drop=True)

    expected_df['column_name'] = (
        expected_df['column_name'].astype(str).str.strip().str.lower()
    )
    raw_expected_type = expected_df['data_type'].fillna('').astype(str).str.strip().str.lower()
    expected_df['expected_length'] = raw_expected_type.apply(extract_length).apply(normalize_length)
    expected_df['data_type'] = (
        raw_expected_type
        .str.replace(r"\(.*\)", "", regex=True)
        .str.strip()
        .apply(normalize_data_type)
    )

    # Query actual DB schema — col_length is computed directly in SQL so we
    # get one comparable string whether the column is character-based
    # (character_maximum_length) or numeric (numeric_precision).
    structure_query = f"""
    SELECT
      column_name,
      data_type,
      CASE
        WHEN character_maximum_length IS NULL THEN COALESCE(numeric_precision::text, '')
        ELSE COALESCE(character_maximum_length::text, '')
      END AS col_length
    FROM pg_catalog.svv_all_columns
    WHERE schema_name = '{DNA_STAGE_SCHEMA}'
      AND table_name  = '{stage_table_name}'
    ORDER BY ordinal_position;
    """

    try:
        actual_df = run_query(structure_query)
    except Exception as e:
        steps.append({
            "step_no": 1,
            "step_name": "DB Structure Query",
            "description": f"SQL Execution Failed: {e}",
            "status": "WARNING",
            "screenshot": None,
            "validation_name": "Structure Validation",
            "test_case_description": "Validate the Structure/Schema of Redshift Stage Table",
            "sql_query": structure_query,
        })
        if update_treeview:
            update_treeview("Structure Validation", pd.DataFrame(steps).drop(columns=["test_case_description"], errors="ignore"))
        return steps

    if actual_df is None or actual_df.empty:
        steps.append({
            "step_no": 1,
            "step_name": "DB Structure Query",
            "description": f"No columns found for {DNA_STAGE_SCHEMA}.{stage_table_name}.",
            "status": "WARNING",
            "screenshot": None,
            "validation_name": "Structure Validation",
            "test_case_description": "Validate the Structure/Schema of Redshift Stage Table",
            "sql_query": structure_query,
        })
        if update_treeview:
            update_treeview("Structure Validation", pd.DataFrame(steps).drop(columns=["test_case_description"], errors="ignore"))
        return steps

    actual_df['column_name'] = actual_df['column_name'].astype(str).str.strip().str.lower()
    actual_df['data_type']   = actual_df['data_type'].fillna('').astype(str).apply(normalize_data_type)
    actual_df['col_length']  = actual_df['col_length'].fillna('').astype(str).apply(normalize_length)

    # Clean column names for matching
    expected_df['column_name'] = expected_df['column_name'].astype(str).str.strip().str.lower()
    actual_df['column_name'] = actual_df['column_name'].astype(str).str.strip().str.lower()

    # Outer join to capture both matching, missing, and extra columns
    merged = pd.merge(
        expected_df,
        actual_df[['column_name', 'data_type', 'col_length']].rename(
            columns={'data_type': 'actual_data_type', 'col_length': 'actual_length'}
        ),
        on='column_name',
        how='outer'
    )

    results = []
    for _, row in merged.iterrows():
        # Apply .strip() and handle missing/NaN representations securely
        exp_col = str(row.get('column_name', '')).strip()
        
        exp_dt = str(row.get('data_type', '')).strip()
        if exp_dt.lower() in ['nan', 'none']:
            exp_dt = ''
            
        act_dt = str(row.get('actual_data_type', '')).strip()
        if act_dt.lower() in ['nan', 'none']:
            act_dt = ''
            
        exp_len = str(row.get('expected_length', '')).strip()
        if exp_len.lower() in ['nan', 'none']:
            exp_len = ''
            
        act_len = str(row.get('actual_length', '')).strip()
        if act_len.lower() in ['nan', 'none']:
            act_len = ''

        # Determine actual column name output based on database presence
        act_col = exp_col if act_dt != '' else ''

        # Strict validation checks
        mismatches = []
        if not act_dt:
            mismatches.append("Missing in DB")
        elif not exp_dt:
            mismatches.append("Missing in ETL Spec")
        else:
            if exp_dt != act_dt:
                mismatches.append("Datatype mismatch")
            if exp_len and exp_len != act_len:
                mismatches.append("Length mismatch")

        status = "PASS" if not mismatches else "; ".join(mismatches)

        results.append({
            "Expected Column Name":    exp_col,
            "Actual Column Name":      act_col,
            "Expected Data Type":      exp_dt,
            "Actual Data Type":        act_dt,
            "Expected Length":         exp_len,
            "Actual Length":           act_len,
            "Status":                  status,
        })

    results_df = pd.DataFrame(results)

    etl_shot = capture_screenshot(expected_df, "etl_structure")
    db_shot   = capture_screenshot(actual_df,   "db_structure")
    cmp_shot  = capture_screenshot(results_df,  "structure_comparison", status_column="Status")

    final_status = "PASS" if (results_df['Status'] == 'PASS').all() else "FAIL"

    steps.extend([
        {
            "step_no": 1,
            "step_name": "ETL Spec Structure",
            "description": "Capture column names, data types, and expected lengths from Redshift Staging Target sheet.",
            "status": "PASS",
            "screenshot": etl_shot,
            "validation_name": "Structure Validation",
            "test_case_description": "Validate the Structure/Schema of Redshift Stage Table"
        },
        {
            "step_no": 2,
            "step_name": "DB Table Structure",
            "description": f"Capture column names, data types, and column lengths from {DNA_STAGE_SCHEMA} table.",
            "status": "PASS",
            "screenshot": db_shot,
            "validation_name": "Structure Validation",
            "sql_query": structure_query,
        },
        {
            "step_no": 3,
            "step_name": "Comparison",
            "description": "Compare column names, data types, and column lengths between ETL spec and DB.",
            "status": final_status,
            "screenshot": cmp_shot,
            "validation_name": "Structure Validation",
            "sql_query": structure_query,
        }
    ])

    if update_treeview:
        update_treeview(
            "Structure Validation",
            pd.DataFrame(steps).drop(columns=["test_case_description"], errors="ignore")
        )

    return steps
