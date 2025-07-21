import functions_framework
import json
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
import os

"""
request.method        # "GET", "POST", etc.
request.path          # "/some/route"
request.headers       # EnvironHeaders dict-like
request.args          # ImmutableMultiDict of query-string params
request.get_json()    # Parsed JSON body (or None)
request.get_data()    # Raw body bytes/str
request.form          # Form fields (for x-www-form-urlencoded)
request.files         # Uploaded files (werkzeug FileStorage)
request.cookies       # Cookies dict
request.remote_addr   # Client IP
"""

# python get the Firestore info from the env variables passed by terraform
database = os.getenv("database_name", "no database_name_found")
collection = os.getenv("collection_name", "no_collection_name_found")
document = os.getenv("document_name", "no_document_name_found")


CORS = {
    "Access-Control-Allow-Origin":  "*",
    "Access-Control-Allow-Methods": "GET,POST,OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type, X-Api-Key",
    "Content-Type": "application/json"
}

try:
    if not firebase_admin._apps:          # avoid double-init in cold-starts
        firebase_admin.initialize_app()
except Exception as e:
    print(e)
    raise "Couldn't Initialize_App check your credentials"
    


@functions_framework.http
def hello_http(request):

    def _json_response(payload: dict, status: int):
        """Return Flask-compatible JSON response with CORS."""
        return (json.dumps(payload), status, CORS)
    
    def declare_db(database, collection, document):
        try:
            # Declare the firestore db
            db = firestore.client(database_id=database)
        except Exception as e:
            print(e)
            raise "An Error Occured. check spelling database"
        try:
            entry = db.collection(collection).document(document)
        except Exception as e:
            print(e)
            raise "An Error Occured. Check Collection, document names"

        return entry

    def get_visitor_count():
       db = declare_db(database, collection, document)
       return db.get().to_dict()
    
    def update_visitor_count():
        db = declare_db(database, collection, document)
        count = get_visitor_count().get("visitor-number", "")
        count+=1
        try:
            db.update({"visitor-number": count})
        except Exception as e:
            print(e)
            raise "Couldn't Update The DB. Validte your syntax"
        
        return True

        # return db.update({"visitor-number": d})

    if(request.method == "GET"):
        res = get_visitor_count()
        visistor_count = res.get("visitor-number", 0)

        body = {
                "message": "Visitor count received",
                "Visitor_Count": visistor_count
            }

        return _json_response(body, 200)
    
    elif (request.method == "POST"):
        res = update_visitor_count()
        visistor_count = get_visitor_count()
        body = {
                "message": "Visitor count Updated",
                "Visitor_Count": visistor_count.get("visitor-number", 0)
            }
        
        if(res):
            return _json_response(body, 200)
        
    elif (request.method == "OPTIONS"):
        # Handle CORS preflight request
        return _json_response("", 204)

    else:
        body = {
            "error": "Method not allowed"
        }
        # Handle unsupported HTTP methods
        return _json_response(body, 405)


