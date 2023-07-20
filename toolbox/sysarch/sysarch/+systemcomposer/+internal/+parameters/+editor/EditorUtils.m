classdef EditorUtils<handle





    methods(Static)
        function navigateToParameterSource(blkHdl,widgeId)
            maskEditor=maskeditor('Get',blkHdl);
            widget=findobj(maskEditor.m_MEData.widgets.toArray,'id',widgeId);
            if~isempty(widget)
                blkPath=blkHdl;
                if(widget.widgetMetaData.isPromotedParameter)
                    promotedProp=findobj(widget.properties,'id','PromotedParametersList');
                    paramName=char(eval(promotedProp.value));
                    idx=strfind(paramName,'/');
                    if~isempty(idx)
                        childBlk=paramName(1:idx(end)-1);
                        blkObj=get_param(blkHdl,'Object');
                        blkPath=[blkObj.getFullName,'/',childBlk];
                    end
                end
                hilite_system(blkPath);
            end
        end
    end
end