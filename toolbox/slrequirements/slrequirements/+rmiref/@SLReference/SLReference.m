


classdef SLReference<handle


    properties
type
docname
itemname
label
command
issue
details
cmd
model
slObj
refData
docId
docText
idx
    end


    methods

        function reference=SLReference(type)
            reference.type=type;
        end

        function overrideCommand(this,newIssue,sessionId)
            [~,args]=rmiref.SLReference.parseCommand(this.command);
            argsString=rmiref.SLReference.cell2args(args);
            newCommand=[rmiref.DocChecker.FIX_CALLBACK...
            ,'(''',sessionId,''', ''',this.type,''', ''',this.docname,''', ''',this.itemname,''', ''',newIssue,''', ',argsString,');'];
            if this.updateCommand(newCommand)
                this.command=newCommand;
                this.cmd=rmiref.DocChecker.FIX_CALLBACK;
            end
        end

        function updateSessionId(this,sessionId)
            prefixLength=length([rmiref.DocChecker.FIX_CALLBACK,'(''']);
            currentCommand=this.command;
            restOfCommand=currentCommand(prefixLength+1:end);
            endOfId=strfind(restOfCommand,'''');
            newCommand=[currentCommand(1:prefixLength),sessionId,restOfCommand(endOfId:end)];
            if this.updateCommand(newCommand)
                this.command=newCommand;
            end
        end

        function markInvalid(this,sessionId)
            this.issue=rmiref.DocChecker.UNSUPPORTED_COMMAND;
            this.details=this.command;
            this.override(rmiref.DocChecker.UNSUPPORTED_COMMAND,'invalid',sessionId);
        end


        function[missingModel,missingObject,pathFixed,labelFixed]=checkInSimulink(this)


            missingModel=false;
            missingObject=false;
            pathFixed='';
            labelFixed='';


            [modelPath,modelName]=fileparts(this.model);


            try
                modelH=get_param(modelName,'Handle');
            catch Mex %#ok<NASGU>,
                try
                    open_system(this.model);
                    modelH=get_param(modelName,'Handle');
                catch Mex1 %#ok<NASGU>
                    if~isempty(modelPath)
                        try
                            open_system(modelName);
                            modelH=get_param(modelName,'Handle');
                        catch Mex2 %#ok<NASGU>
                            modelH=[];
                        end
                    else
                        modelH=[];
                    end
                end
            end

            if isempty(modelH)
                missingModel=true;
                return;
            end


            if~isempty(modelPath)
                actualFullName=get_param(modelH,'FileName');
                [actualPath]=fileparts(actualFullName);
                if rmiref.DocChecker.pathMismatch(modelPath,actualPath)
                    if this.fixPath(actualPath,modelName)
                        pathFixed=modelPath;
                    else
                        pathFixed='FAILED TO FIX PATH';
                    end
                end
            end

            objH=rmiref.SLReference.resolve(modelH,this.slObj);

            if isempty(objH)
                missingObject=true;
            else

                [~,dispstr]=rmi.objinfo(objH);


                my_chars=double(dispstr);
                dispstr(my_chars<32|my_chars==127)=' ';
                storedLabel=this.label;
                my_chars=double(storedLabel);
                storedLabel(my_chars<32|my_chars==127)=' ';

                if~strcmp(dispstr,storedLabel)
                    if this.updateLabel(dispstr)
                        labelFixed=this.label;
                        this.label=dispstr;
                    else
                        labelFixed='FAILED TO FIX LABEL';
                    end
                end
            end

        end

        function success=assignRefData(this,sessionId,varargin)
            this.assignDocData();
            if this.assignCmdData(varargin{:})
                [this.issue,this.details]=rmiref.SLReference.parseLabel(this.label);
                if strcmp(this.cmd,rmiref.DocChecker.FIX_CALLBACK)
                    this.updateSessionId(sessionId);
                    if strcmp(this.issue,rmiref.DocChecker.UNRESOLVED_OBJECT)
                        this.details=[this.slObj,' (',this.details,')'];
                    end
                end
                success=true;
            else
                this.markInvalid(sessionId);
                success=false;
            end
        end

        function pathFixed=fixPath(this,actualPath,modelName)
            newFullName=get_param(modelName,'FileName');
            if isempty(strfind(newFullName,actualPath))
                fprintf(1,'WARNING: intended actualPath %s not matched for %s\n',...
                actualPath,modelName);
            end
            this.model=newFullName;
            [~,args]=rmiref.SLReference.parseCommand(this.command);
            args{1}=newFullName;
            newCommand=['rmiobjnavigate(',this.cell2args(args),');'];
            if this.updateCommand(newCommand)
                pathFixed=true;
                this.command=newCommand;
                this.model=newFullName;
            else
                pathFixed=false;
            end
        end

        function override(this,issue,icon,sessionId)

            this.issue=issue;

            if this.isHttpLink()


            else


                data=[this.command,' | ',this.label];
                if this.updateData(data)
                    this.refData=data;
                end


                if strcmp(issue,rmiref.DocChecker.UNSUPPORTED_COMMAND)
                    fprintf(1,'Keeping original unsupported command for item %s: %s\n',...
                    this.itemname,this.command);
                else

                    this.overrideCommand(issue,sessionId);


                    if strcmp(issue,rmiref.DocChecker.UNRESOLVED_MODEL)
                        newLabel=[issue,': ',this.model];
                        this.details=strrep(this.model,'\','/');
                    else

                        newLabel=[issue,': ',this.details];

                        if strcmp(issue,rmiref.DocChecker.UNRESOLVED_OBJECT)
                            this.details=[this.slObj,' (',this.details,')'];
                        end
                    end
                    if this.updateLabel(newLabel)
                        this.label=newLabel;
                    end
                end
            end


            this.updateBitmap(icon);
        end

        function yesno=isHttpLink(this)

            if strcmp(this.type,'doors')
                yesno=this.isLink;
            else
                yesno=~isempty(this.hLink);
            end
        end

        function updated=updateModel(this,newModelPath,args)
            updated=false;
            oldModelPath=args{1};
            [origCommand,origLabel]=rmiref.SLReference.parseData(this.refData);

            newCommand=strrep(origCommand,oldModelPath,newModelPath);
            if this.updateCommand(newCommand)
                this.command=newCommand;
                this.model=newModelPath;

                [~,oldName,~]=fileparts(oldModelPath);
                [~,newName,~]=fileparts(newModelPath);
                newLabel=regexprep(origLabel,oldName,newName);
                if this.updateLabel(newLabel)
                    this.label=newLabel;
                    this.refData='';
                    this.updateData('');
                end
                this.updateBitmap('normal');
                updated=true;
            end
        end

        function viewInSimulink(this)
            eval(this.command);
        end

        function success=hasIncoming(this)
            if isempty(this.issue)
                [~,src]=fileparts(this.model);
                modelH=get_param(src,'Handle');
                obj=this.slObj;
                if isempty(obj)
                    objH=modelH;
                elseif obj(1)==':'
                    objH=Simulink.ID.getHandle([src,obj]);
                else
                    objH=rmisl.guidlookup(modelH,obj);
                end

                reqs=rmi.getReqs(objH);
                found=false;
                for i=1:length(reqs)
                    if isempty(strfind(reqs(i).doc,this.docname))
                        continue;
                    end
                    if isempty(strfind(reqs(i).id,this.docId))
                        continue;
                    end
                    found=true;
                end
                success=found;
            else

                success=true;
            end
        end


    end

    methods(Static)

        function iconPathName=fullIconPathName(iconName)
            if strcmp(iconName,'normal')



                defaultIconPath=fullfile(matlabroot,'toolbox','shared','reqmgt','icons','slicon.bmp');
                if rmi.settings_mgr('get','linkSettings','slrefCustomized')
                    userIconPath=rmi.settings_mgr('get','linkSettings','slrefUserBitmap');
                    if isempty(userIconPath)
                        myIcon=defaultIconPath;
                    elseif exist(userIconPath,'file')==2
                        myIcon=userIconPath;
                    else
                        myIcon=fullfile(matlabroot,'toolbox','slrequirements','slrequirements','resources','icons','normal.bmp');
                    end
                else
                    myIcon=defaultIconPath;
                end
            else
                myIcon=fullfile(matlabroot,'toolbox','slrequirements','slrequirements','resources','icons',[iconName,'.bmp']);
            end
            if exist(myIcon,'file')==2
                iconPathName=myIcon;
            else
                warning(message('Slvnv:reqmgt:SLReference',iconName));
                iconPathName=[];
            end
        end

        function args=cell2args(array)
            args='';
            for i=1:length(array)
                if ischar(array{i})
                    args=[args,'''',array{i},''', '];%#ok<AGROW>
                else
                    args=[args,num2str(array{i}),', '];%#ok<AGROW>
                end
            end
            if~isempty(args)
                args=args(1:end-2);
            end
        end

        function[command,label]=parseData(string)
            separator=strfind(string,' | ');
            if isempty(separator)
                command='';
                label=string;
            else
                command=string(1:separator(1)-1);
                label=string(separator(1)+3:end);
            end
        end

        function[command,args]=parseCommand(string)
            tokens=regexp(string,'^([^\( ])+ *\(([^\)]+)','tokens');
            command=tokens{1}{1};
            args=eval(['{',tokens{1}{2},'}']);
        end

        function[issue,details]=parseLabel(string)
            separator=strfind(string,': ');
            if isempty(separator)
                issue='';
                details=string;
            else
                issue=string(1:separator(1)-1);
                details=string(separator(1)+2:end);
            end
        end

        function yesno=isDDLink(link)
            [~,~,ext]=fileparts(link.model);
            yesno=strcmp(ext,'.sldd');
        end

        function yesno=isMultilink(link)
            yesno=~isempty(regexp(link.issue,'^\d+ links$','once'));
        end


        objH=resolve(modelH,objId)

    end




    methods(Abstract)
        viewInDocument(this)
        deleted=deleteSrc(this)
        labelUpdated=updateLabel(this,newLabel)
        dataUpdated=updateData(this,newData)
        commandUpdated=updateCommand(this,newCommand)
        bitmpaUpdated=updateBitmap(this,newIconName)
        assignDocData(this)
        ok=assignCmdData(this)
        restored=restore(this)
    end

    methods(Abstract,Static)
    end


end
