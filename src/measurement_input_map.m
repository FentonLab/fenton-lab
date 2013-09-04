% Creates an AnalysisRecord input map from an iterable collection of 
% Measurements.
%
% When providing a collection of Measurements to an Epoch AnalysisRecord,
% it's sometimes convenient to use the Measurements' names as their input
% name. This function creates a java.util.HashMap<String,Measurement> using
% the Measurements' names as keys. The result of this function can be
% passed as the inputSources parameter to Epoch.addAnalysisRecord(...).

function inputs = measurement_input_map(iterable_measurements)
    inputs = java.util.HashMap();
    measurements = iterable_measurements.iterator();
    while(measurements.hasNext())
        measurement = measurements.next();
        inputs.put(measurement.getName(), measurement);
    end
end