



classdef TranslationLog<handle

    properties(GetAccess=public,SetAccess=private)

Messages

Parameters

Stubs

Intrinsics

Checks

Randoms
    end

    properties
IlFormat
    end

    properties(Access=private)

        ReturnCode=-1
    end

    properties(Constant=true,Hidden=true)
        CgelFormat='CGEL'
        VvirFormat='VVIR'
    end

    methods(Access=public)
        function obj=TranslationLog()
            obj.Parameters=containers.Map('KeyType','char','ValueType','char');
            obj.Messages=sldv.code.internal.TranslationMessage.empty();
            obj.Stubs=struct('Type',{},...
            'Function',{});
            obj.Intrinsics=struct('Name',{},...
            'Sig',{});
            obj.Checks=struct('Fcn',{},...
            'Status',{},...
            'Category',{},...
            'File',{},...
            'Line',[]);
            obj.Randoms=struct('Description',{},...
            'Type',{},...
            'File',{},...
            'Line',[]);
            obj.IlFormat=obj.CgelFormat;
        end

        function add(obj,message)
            obj.Messages(end+1)=message;
        end

        function ok=isOk(obj)
            ok=(obj.ReturnCode==0);
            if ok
                hasError=any(strcmp({obj.Messages.Type},...
                sldv.code.internal.TranslationMessage.ErrorType));
                hasInternalError=any(strcmp({obj.Messages.Type},...
                sldv.code.internal.TranslationMessage.InternalErrorType));
                ok=~hasError&&~hasInternalError;
            end
        end

        function stubs=getStubs(obj)
            stubs=obj.Stubs;
        end

        function checks=getChecks(obj)
            checks=obj.Checks;
        end

        function vvir=isVvirIl(obj)
            vvir=strcmp(obj.IlFormat,obj.VvirFormat);
        end


        function description=getCheckDescription(obj,index)
            category=obj.Checks(index).Category;
            extraArgs={};
            switch category
            case 'ZDV'
                msgId='sldv_sfcn:sldv_sfcn:rteZDVLabel';
            case 'OBAI'
                msgId='sldv_sfcn:sldv_sfcn:rteOBAILabel';
            case{'IDP','FPPF'}
                msgId='sldv_sfcn:sldv_sfcn:rteIDPLabel';
            case 'NIP'
                msgId='sldv_sfcn:sldv_sfcn:rteNIPLabel';
            case 'NNR'
                msgId='sldv_sfcn:sldv_sfcn:rteNNTLabel';
            otherwise
                msgId='sldv_sfcn:sldv_sfcn:rteDefaultLabel';
                extraArgs={category};
            end

            msg=message(msgId,obj.Checks(index).File,obj.Checks(index).Line,extraArgs{:});
            description=msg.getString();
        end

        function intrinsics=getIntrinsics(obj)
            intrinsics=obj.Intrinsics;
        end

        function errorMessages=getErrors(obj)
            errorIndexes=strcmp({obj.Messages.Type},sldv.code.internal.TranslationMessage.ErrorType);
            internalErrors=strcmp({obj.Messages.Type},sldv.code.internal.TranslationMessage.InternalErrorType);
            errorMessages=obj.Messages(errorIndexes|internalErrors);
        end

        function warningMessages=getWarnings(obj)
            warningIndexes=strcmp({obj.Messages.Type},sldv.code.internal.TranslationMessage.WarningType);
            warningMessages=obj.Messages(warningIndexes);
        end

        function randoms=getRandoms(obj)
            if sldv.code.internal.feature('randoms')
                randoms=obj.Randoms;
            else
                volatileIndexes=strcmp({obj.Randoms.Type},'volatile');
                externalIndexes=strcmp({obj.Randoms.Type},'extern');
                stubIndexes=strcmp({obj.Randoms.Type},'stub');

                randoms=obj.Randoms(volatileIndexes|externalIndexes|stubIndexes);
            end
        end

        function setTranslationStatus(obj,status)
            obj.ReturnCode=status;
        end

        function initFromVvirLoweringInfo(obj,vvirLoweringInfo,posConverter)

            loweringMessages=vvirLoweringInfo.getMessages();

            for ii=1:numel(loweringMessages)
                msg=loweringMessages(ii);

                message=sldv.code.internal.TranslationMessage(msg.Criticality,...
                msg.Id,...
                {});

                sourceFile=msg.File;
                sourceLine=msg.Line;
                keepMessage=true;
                if~isempty(posConverter)&&~isempty(sourceFile)


                    [sourceFile,sourceLine,keepMessage]=posConverter.convertPos(sourceFile,sourceLine);
                end

                if keepMessage
                    message.setSourceLocation(sourceFile,sourceLine);
                    obj.Messages(end+1)=message;
                end
            end


            stubs=vvirLoweringInfo.getStubInfo();
            numStubs=numel(stubs);
            if numStubs>0
                obj.Stubs(1:numStubs)=struct('Type','','Function','');
                for ii=1:numStubs
                    stub=stubs(ii);
                    obj.Stubs(ii).Type=stub.Type;
                    obj.Stubs(ii).Function=stub.Function;
                end
            end


            checks=vvirLoweringInfo.getCheckInfo();
            numChecks=numel(checks);
            if numChecks>0
                obj.Checks(1:numChecks)=struct('Fcn','','Status','orange','Category','',...
                'File','','Line',0);

                for ii=1:numChecks
                    check=checks(ii);

                    checkStatus=check.Color;
                    checkFile=check.File;
                    checkLine=check.Line;

                    if~isempty(posConverter)
                        [checkFile,checkLine,found]=posConverter.convertPos(checkFile,checkLine);
                    else
                        found=true;
                    end

                    if~found
                        if strcmp(check.Color,'red')


                            obj.add(sldv.code.internal.TranslationMessage(sldv.code.internal.TranslationMessage.ErrorType,...
                            'sldv_sfcn:il2cgel:runTimeErrorInUserCode'));
                        else

                            checkStatus='';
                        end
                    end

                    obj.Checks(ii).Fcn=check.Function;
                    obj.Checks(ii).Category=check.Type;
                    obj.Checks(ii).Status=checkStatus;
                    obj.Checks(ii).File=checkFile;
                    obj.Checks(ii).Line=checkLine;
                end
            end


            events=vvirLoweringInfo.getEventInfo();
            numEvents=numel(events);
            if numEvents>0
                obj.Randoms(1:numEvents)=struct('Description','',...
                'Type','',...
                'File','','Line',0);
                for ii=1:numEvents
                    event=events(ii);

                    randomType=event.Type;
                    randomFile=event.File;
                    randomLine=event.Line;
                    randomDescription=event.Cause;

                    if~isempty(posConverter)
                        [randomFile,randomLine,found]=posConverter.convertPos(randomFile,randomLine);
                    else
                        found=false;
                    end

                    if~found
                        randomDescription='';
                        randomFile='';
                        randomLine=0;
                    end

                    obj.Randoms(ii).Description=randomDescription;
                    obj.Randoms(ii).File=randomFile;
                    obj.Randoms(ii).Line=randomLine;
                    obj.Randoms(ii).Type=randomType;
                end


                obj.Randoms(strcmp({obj.Randoms.File},''))=[];
            end
        end
    end
end



