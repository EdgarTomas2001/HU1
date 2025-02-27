import sys
import os
import json
import numpy as np
from .NeuralNetwork import NeuralNetwork

class MLBridge:
    def __init__(self):
        self.model = None
        self.input_dim = 10  # Default input dimension, adjust based on your feature set

    def load_model(self, model_path, scaler_path):
        try:
            if not os.path.exists(model_path) or not os.path.exists(scaler_path):
                return {"status": "error", "message": "Model or scaler file not found"}

            self.model = NeuralNetwork(input_dim=self.input_dim)
            self.model.load_model(model_path, scaler_path)
            return {"status": "success"}
        except Exception as e:
            return {"status": "error", "message": str(e)}

    def predict(self, features):
        try:
            features_array = np.array(features).reshape(1, -1)
            prediction = self.model.predict(features_array)
            return {"status": "success", "prediction": float(prediction[0][0])}
        except Exception as e:
            return {"status": "error", "message": str(e)}

    def process_command(self, command_str):
        try:
            command = json.loads(command_str)
            action = command.get("action")
            params = command.get("params", {})

            if action == "load_model":
                return self.load_model(params["model_path"], params["scaler_path"])
            elif action == "predict":
                return self.predict(params["features"])
            else:
                return {"status": "error", "message": f"Unknown action: {action}"}

        except Exception as e:
            return {"status": "error", "message": str(e)}

def main():
    bridge = MLBridge()
    
    while True:
        try:
            command = input().strip()
            if not command:
                continue

            result = bridge.process_command(command)
            print(json.dumps(result))
            sys.stdout.flush()

        except EOFError:
            break
        except Exception as e:
            print(json.dumps({"status": "error", "message": str(e)}))
            sys.stdout.flush()

if __name__ == "__main__":
    main()