


classdef RangeRecord<handle

    properties(GetAccess='public',SetAccess='public')
        model;
        isIssueRange;
        tag;
        instanceHandle;
        derivedMax;
        derivedMin;
        derivedRangeIntervals;
        isEmptyRange;
        containsNaN;
        isSFRecord;
        type;

        derivedRWVMin;
        derivedRWVMax;
        derivedSIMin;
        derivedSIMax;
        emlId;
    end

    methods(Access='public')

        function obj=RangeRecord(model,url)
            obj.model=model;
            obj.isIssueRange=false;
            obj.tag=char(url);
            obj.instanceHandle=[];
            obj.derivedMax=[];
            obj.derivedMin=[];
            obj.derivedRangeIntervals=[];
            obj.isEmptyRange=false;
            obj.isSFRecord=0;
            obj.containsNaN=false;
            obj.type='double';

            obj.derivedRWVMin=0;
            obj.derivedRWVMax=0;
            obj.derivedSIMin=0;
            obj.derivedSIMax=0;
            obj.emlId=[];
        end

        function str=toString(obj)
            str='';
            propertiesCell=properties(obj);
            for propCount=1:size(propertiesCell,1)
                propName=propertiesCell{propCount,1};
                propVal=eval(sprintf('obj.%s',propName));
                if isa(propVal,'numeric')
                    str=sprintf('%s%20s : %g\n',str,propName,propVal);
                elseif isa(propVal,'char')
                    str=sprintf('%s%20s : %s\n',str,propName,propVal);
                elseif isa(propVal,'logical')
                    if propVal
                        str=sprintf('%s%20s : true\n',str,propName);
                    else
                        str=sprintf('%s%20s : false\n',str,propName);
                    end
                elseif isa(propVal,'fxptds.MATLABIdentifier')
                    str=sprintf('%s%20s : %s\n',str,propName,propVal.getDisplayName);
                    str=sprintf('%s%20s : %s\n',str,'EMLIdType',class(propVal));
                    str=sprintf('%s%20s : %s\n',str,'EMLIdKey',propVal.UniqueKey);
                else
                    str=sprintf('%s%20s : No known display method for properties with type %s.  Please update toString() method in RangeRecord class.\n',str,propName,class(propVal));
                end


            end
        end
    end

end


