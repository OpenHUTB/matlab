function expValues=loadViewerPreference(expFields)







    expValues={};
    assert((nargin==1),'Incorrect number of input arguments');

    assert(iscell(expFields)&&(numel(expFields)>0),...
    'Incorrect input arguments');

    if ispref('Simscape','VariableViewer')
        obj=getpref('Simscape','VariableViewer');


        if isstruct(obj)
            actFields=fieldnames(obj);

            if isequal(actFields,expFields)
                expValues=struct2cell(obj);
            else




                expValues=repmat({''},1,numel(expFields));
                actValues=struct2cell(obj);
                [~,expIdx,actIdx]=intersect(expFields,actFields);
                expValues(expIdx)=actValues(actIdx);
            end

        else
            pm_warning('physmod:common:dataservices:core:state:CorruptedPreference');
        end
    end

end
