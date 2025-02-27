import numpy as np
from sklearn.preprocessing import StandardScaler
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense, Dropout
from tensorflow.keras.optimizers import Adam
from tensorflow.keras.callbacks import EarlyStopping
import joblib
import os

class NeuralNetwork:
    def __init__(self, input_dim, hidden_layers=[64, 32], dropout_rate=0.2):
        self.input_dim = input_dim
        self.hidden_layers = hidden_layers
        self.dropout_rate = dropout_rate
        self.model = None
        self.scaler = StandardScaler()
        
    def build_model(self):
        model = Sequential()
        
        # Input layer
        model.add(Dense(self.hidden_layers[0], input_dim=self.input_dim, activation='relu'))
        model.add(Dropout(self.dropout_rate))
        
        # Hidden layers
        for units in self.hidden_layers[1:]:
            model.add(Dense(units, activation='relu'))
            model.add(Dropout(self.dropout_rate))
        
        # Output layer
        model.add(Dense(1, activation='linear'))
        
        # Compile model
        model.compile(optimizer=Adam(learning_rate=0.001),
                    loss='mean_squared_error',
                    metrics=['mae'])
        
        self.model = model
        return model
    
    def preprocess_data(self, X, y=None, training=False):
        if training:
            X_scaled = self.scaler.fit_transform(X)
            return X_scaled, y
        return self.scaler.transform(X)
    
    def train(self, X, y, validation_split=0.2, epochs=100, batch_size=32):
        if self.model is None:
            self.build_model()
        
        # Preprocess data
        X_scaled, y = self.preprocess_data(X, y, training=True)
        
        # Early stopping callback
        early_stopping = EarlyStopping(
            monitor='val_loss',
            patience=10,
            restore_best_weights=True
        )
        
        # Train model
        history = self.model.fit(
            X_scaled, y,
            validation_split=validation_split,
            epochs=epochs,
            batch_size=batch_size,
            callbacks=[early_stopping],
            verbose=1
        )
        
        return history
    
    def predict(self, X):
        if self.model is None:
            raise ValueError("Model not trained yet!")
        
        # Preprocess input data
        X_scaled = self.preprocess_data(X)
        
        # Make predictions
        return self.model.predict(X_scaled)
    
    def save_model(self, model_path, scaler_path):
        # Create directory if it doesn't exist
        os.makedirs(os.path.dirname(model_path), exist_ok=True)
        
        # Save model and scaler
        self.model.save(model_path)
        joblib.dump(self.scaler, scaler_path)
    
    def load_model(self, model_path, scaler_path):
        from tensorflow.keras.models import load_model
        
        # Load model and scaler
        self.model = load_model(model_path)
        self.scaler = joblib.load(scaler_path)