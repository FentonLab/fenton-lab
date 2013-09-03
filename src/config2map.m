% Converts a Fenton-lab Area configuration XML to Java Map
% 
% Nested configuration(s) are flattened to the EquipmentSetup style, e.g.
%     { device.part.config = value }
% 
% Parameters:
% 
%     xmlPath: string
%         Path to configuration (cfg) file
%     deviceName: string
%         Top-level device name (e.g. 'Arena')
%         
% Returns:
%     java.util.Map of flattened configuration entries
    
% Copyright (c) 2013 Physion Consulting LLC

function m = config2map(xmlPath, deviceName)
    import ovation.*;
    
    s = parseXML(xmlPath);
    s.Name = deviceName;
    
    m = java.util.HashMap();
    m = flattenStruct(s, m);
end

function result = flattenStruct(s, result)
    
    for a = s.Attributes
        value = a.Value;
        
        if(ischar(value))
            value = java.lang.String(value);
        elseif((isnumeric(value) || islogical(value)) && numel(value) > 1)
            if(isvector(value))
                value = NumericData(value);
            else
                value = NumericData(reshape(value, 1, numel(value)),...
                    size(value));
            end
        elseif(isempty(value))
            value = '<empty>';
        elseif(isa(value, 'function_handle'))
            value = func2str(value);
        elseif(iscellstr(value))
            value = cell2mat(value);
        elseif(iscell(value))
            id = 'ovation:struct2map:unsupported_value';
            msg = ['struct2map does not support cell-array values (key ' keys{i} ')'];
            if(opts.strict)
                error(id, msg);
            else
                warning(id, msg);
            end
            continue;
        end
        
        result.put([s.Name '.' a.Name], value);
    end
    
    for c = s.Children
        if ~isempty(c.Attributes) || ~isempty(c.Children)
            result.putAll(flattenStruct(c, result));
        end
    end
    
end

%% This code from http://www.mathworks.com/help/matlab/ref/xmlread.html

function theStruct = parseXML(filename)
    % PARSEXML Convert XML file to a MATLAB structure.
    try
        tree = xmlread(filename);
    catch
        error('Failed to read XML file %s.',filename);
    end
    
    % Recurse over child nodes. This could run into problems
    % with very deeply nested trees.
    try
        theStruct = parseChildNodes(tree);
    catch
        error('Unable to parse XML file %s.',filename);
    end
end

% ----- Local function PARSECHILDNODES -----
function children = parseChildNodes(theNode)
    % Recurse over node children.
    children = [];
    if theNode.hasChildNodes
        childNodes = theNode.getChildNodes;
        numChildNodes = childNodes.getLength;
        allocCell = cell(1, numChildNodes);
        
        children = struct(             ...
            'Name', allocCell, 'Attributes', allocCell,    ...
            'Data', allocCell, 'Children', allocCell);
        
        for count = 1:numChildNodes
            theChild = childNodes.item(count-1);
            children(count) = makeStructFromNode(theChild);
        end
    end
end

% ----- Local function MAKESTRUCTFROMNODE -----
function nodeStruct = makeStructFromNode(theNode)
    % Create structure of node info.
    
    nodeStruct = struct(                        ...
        'Name', char(theNode.getNodeName),       ...
        'Attributes', parseAttributes(theNode),  ...
        'Data', '',                              ...
        'Children', parseChildNodes(theNode));
    
    if any(strcmp(methods(theNode), 'getData'))
        nodeStruct.Data = char(theNode.getData);
    else
        nodeStruct.Data = '';
    end
end

% ----- Local function PARSEATTRIBUTES -----
function attributes = parseAttributes(theNode)
    % Create attributes structure.
    
    attributes = [];
    if theNode.hasAttributes
        theAttributes = theNode.getAttributes;
        numAttributes = theAttributes.getLength;
        allocCell = cell(1, numAttributes);
        attributes = struct('Name', allocCell, 'Value', ...
            allocCell);
        
        for count = 1:numAttributes
            attrib = theAttributes.item(count-1);
            attributes(count).Name = char(attrib.getName);
            attributes(count).Value = char(attrib.getValue);
        end
    end
end