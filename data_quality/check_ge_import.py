import great_expectations as gx

print("Great Expectations version:", gx.__version__)
context = gx.get_context()
print("Context type:", type(context).__name__)
print("GE import and context creation succeeded.")
