classdef redirectInterceptor<handle




    methods


        function result=process(~,aMsgRecord)
            result=[];

            if(~isempty(aMsgRecord.MessageId))







                if(strcmp(aMsgRecord.Severity,'ERROR'))
                    diagStruct.severity=0;
                elseif(strcmp(aMsgRecord.Severity,'HIGH_PRIORITY_WARNING'))
                    diagStruct.severity=1;
                elseif(strcmp(aMsgRecord.Severity,'WARNING'))
                    diagStruct.severity=1;
                elseif(strcmp(aMsgRecord.Severity,'INFO'))
                    diagStruct.severity=2;
                else
                    diagStruct.severity=0;
                end


                if(isfield(aMsgRecord,'Causes'))
                    diagStruct.causes=aMsgRecord.Causes;
                end
                diagStruct.msgid=aMsgRecord.MessageId;
                diagStruct.msgStr=aMsgRecord.Message;

                diagStruct.component=aMsgRecord.Component;





                if(~isempty(aMsgRecord.ModelName))
                    try
                        diagStruct.slobjH=get_param(aMsgRecord.ModelName,'handle');






                        if(diagStruct.severity==0)||(strcmp(aMsgRecord.MessageId,'Simulink:Engine:WarnAlgLoopsFound'))
                            sldvshareprivate('reportDiagnostic',diagStruct);
                        end
                    catch MEx %#ok<NASGU>




                    end
                end
            end
        end
    end
end
