function parsedResults=parseCGIRResults(obj,key)




    if isKey(obj.resultMap,key)
        parsedResults=obj.resultMap(key);
        assert(isfield(parsedResults,'tag'));

        valid_indices=cellfun(@containsValidMATLABSID,parsedResults.tag);
        parsedResults.tag=parsedResults.tag(valid_indices);


        for i=1:numel(parsedResults.tag)
            sid=parsedResults.tag{i}.sid;
            [path,~,pos]=coder.report.RegisterCGIRInspectorResults.parseSID(sid);
            posFields=split(pos,'-');
            parsedResults.tag{i}.path=path;
            parsedResults.tag{i}.startPos=str2double(posFields{1});
            parsedResults.tag{i}.endPos=str2double(posFields{2});
        end
    else
        parsedResults.tag={};
    end

    function isValid=containsValidMATLABSID(tag)

        assert(isa(tag.sid,'char'));



        isValid=false;
        if~isempty(tag.sid)
            [~,~,pos]=coder.report.RegisterCGIRInspectorResults.parseSID(tag.sid);
            isValid=Advisor.BaseRegisterCGIRInspectorResults.isValidMATLABFcnStartEndPostFix(pos);
        end


