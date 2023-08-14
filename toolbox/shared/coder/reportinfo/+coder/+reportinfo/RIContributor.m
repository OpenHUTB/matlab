classdef(Abstract)RIContributor<coder.internal.gui.Advisable







    properties(Abstract,SetAccess=protected)
        Data{mustBeMessageStruct}
    end
end

function mustBeMessageStruct(a)
    messageFields={'MessageID';'MessageType';'Text';'ScriptID';...
    'TextStart';'TextLength';'Category';'SubCategory'};
    if~isempty(a)&&(~isa(a,'struct')||~isequal(fieldnames(a),messageFields))
        error(['Value assigned to Data property must be a struct with fields: ',...
        strjoin(messageFields,', ')])
    end
end