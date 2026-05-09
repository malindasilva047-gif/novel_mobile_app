#!/usr/bin/env python3
"""
Initialize the novel_app database with the enhanced schema.
Run from: python backend/scripts/init_db.py
"""

import os
import sys
from pathlib import Path

# Add parent to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent))

import mysql.connector
from dotenv import load_dotenv

# Load environment
load_dotenv(os.path.join(Path(__file__).parent.parent, '.env.local'))

def init_database():
    """Read and execute SQL schema."""
    try:
        # Read SQL file
        sql_file = Path(__file__).parent.parent / 'sql' / 'setup_v2.sql'
        with open(sql_file, 'r', encoding='utf-8') as f:
            sql_content = f.read()
        
        # Connect to MySQL
        conn = mysql.connector.connect(
            host=os.getenv("MYSQL_HOST", "127.0.0.1"),
            port=int(os.getenv("MYSQL_PORT", "3306")),
            user=os.getenv("MYSQL_USER", "root"),
            password=os.getenv("MYSQL_PASSWORD", ""),
            autocommit=False,
        )
        
        cursor = conn.cursor()
        
        # Disable foreign key checks during initialization
        try:
            cursor.execute("SET FOREIGN_KEY_CHECKS=0")
            conn.commit()
        except:
            pass
        
        # Parse statements more carefully
        # Remove comments and split by semicolons
        statements = []
        current_stmt = ""
        in_string = False
        string_char = None
        
        for i, char in enumerate(sql_content):
            # Handle strings
            if char in ('"', "'") and (i == 0 or sql_content[i-1] != '\\'):
                if not in_string:
                    in_string = True
                    string_char = char
                elif char == string_char:
                    in_string = False
            
            # Handle statement end
            if char == ';' and not in_string:
                current_stmt += char
                stmt = current_stmt.strip()
                if stmt and not stmt.startswith('--'):
                    statements.append(stmt)
                current_stmt = ""
            else:
                current_stmt += char
        
        # Execute first three statements separately: DROP, CREATE, USE
        database_ready = False
        executed = 0
        
        for idx, statement in enumerate(statements):
            try:
                # After CREATE DATABASE, reconnect to use that database
                if "CREATE DATABASE" in statement and not database_ready:
                    cursor.execute(statement)
                    conn.commit()
                    executed += 1
                    print(f"  → CREATE DATABASE...")
                    cursor.close()
                    conn.close()
                    # Reconnect to the new database
                    conn = mysql.connector.connect(
                        host=os.getenv("MYSQL_HOST", "127.0.0.1"),
                        port=int(os.getenv("MYSQL_PORT", "3306")),
                        user=os.getenv("MYSQL_USER", "root"),
                        password=os.getenv("MYSQL_PASSWORD", ""),
                        database=os.getenv("MYSQL_DATABASE", "novel_app_db"),
                        autocommit=False,
                    )
                    cursor = conn.cursor()
                    # Disable FK checks again
                    try:
                        cursor.execute("SET FOREIGN_KEY_CHECKS=0")
                        conn.commit()
                    except:
                        pass
                    database_ready = True
                    continue
                
                # Skip USE statements as we're now connected to the right database
                if "USE " in statement.upper():
                    continue
                
                cursor.execute(statement)
                conn.commit()
                executed += 1
                # Log CREATE TABLE statements
                if "CREATE TABLE" in statement.upper():
                    table_name = statement.split("CREATE TABLE")[1].split("(")[0].strip()
                    print(f"  → Created table: {table_name}")
            except mysql.connector.Error as e:
                error_msg = str(e).lower()
                # Allow database doesn't exist errors for DROP, and retry for CREATE
                if "drop database" in statement.lower() and "database" in error_msg and "doesn't exist" in error_msg:
                    print(f"  (skipped - database doesn't exist yet)")
                    continue
                elif "already exists" in error_msg and "create database" in statement.lower():
                    print(f"  (database already exists, proceeding...)")
                    continue
                elif "already exists" not in error_msg:
                    print(f"Error: {e}\nStatement: {statement[:200]}...")
                    raise
        
        cursor.close()
        conn.close()
        
        # Reconnect and re-enable FK checks
        try:
            conn = mysql.connector.connect(
                host=os.getenv("MYSQL_HOST", "127.0.0.1"),
                port=int(os.getenv("MYSQL_PORT", "3306")),
                user=os.getenv("MYSQL_USER", "root"),
                password=os.getenv("MYSQL_PASSWORD", ""),
                database=os.getenv("MYSQL_DATABASE", "novel_app_db"),
            )
            cursor = conn.cursor()
            cursor.execute("SET FOREIGN_KEY_CHECKS=1")
            conn.commit()
            cursor.close()
            conn.close()
        except:
            pass
        
        print(f"✓ Database initialized successfully! ({executed} statements executed)")
        print("✓ Tables created with new schema")
        print("✓ Categories, genres, and sample data seeded")
        
    except Exception as e:
        print(f"✗ Database initialization failed: {e}")
        sys.exit(1)

if __name__ == '__main__':
    init_database()
