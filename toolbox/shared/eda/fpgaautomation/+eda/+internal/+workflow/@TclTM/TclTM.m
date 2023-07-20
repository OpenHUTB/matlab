classdef TclTM<handle







    properties(SetAccess=public,GetAccess=public,Hidden=true)
    end




    properties(SetAccess=protected,GetAccess=protected,Hidden=true)

    end




    methods(Access='public')


        function h=TclTM(varargin)
        end



        function tclsh=getTclShell(h)
            tclsh='xtclsh';
        end



        function[status,cmd]=setVar(h,varname,subcmd)
            cmd=['set ',varname,' [',subcmd,']',char(10)];
            status='';
        end

        function[status,cmd]=openFile(h,filename,varname)
            subcmd=['open "',filename,'" w'];
            [~,cmd]=h.setVar(varname,subcmd);
            status='';
        end


        function[status,cmd]=closeFile(h,varname)
            cmd=['close $',varname,char(10)];
            status='';
        end

        function[status,cmd]=writeFile(h,varname,subcmd)
            cmd=['puts $',varname,' [',subcmd,']',char(10)];
            status='';
        end



        function[status,cmd]=openProject(h,name,projPath)
            if nargin<3
                projDisp=name;
            else
                projDisp=h.getProjectLink(projPath);
            end

            cmd=['project open ',name,char(10)];
            status=[formatDispStr('Project: ',2)...
            ,formatDispStr(projDisp,3)];
        end

        function[status,cmd]=closeProject(h)
            cmd=['project close',char(10)];
            status='';
        end

        function[status,cmd]=addFiles(h,srcfiles)
            cmd='';
            status='';
            for n=1:length(srcfiles)
                file=char(srcfiles(n));
                file=h.addPathQuote(file);
                cmd=[cmd,'xfile add ',file,char(10)];
                status=[status,formatDispStr(char(srcfiles(n)),3)];
            end
        end

        function[status,cmd]=removeFiles(h,srcfiles)
            cmd='';
            status='';
            for n=1:length(srcfiles)
                file=char(srcfiles(n));
                file=h.addPathQuote(file);
                cmd=[cmd,'xfile remove ',file,char(10)];
                status=[status,formatDispStr(char(srcfiles(n)),3)];
            end
        end

        function[status,cmd]=setProp(h,prop)



            cmd='';
            status=formatDispStr('Property Settings:',2);
            for n=1:length(prop)
                if~isempty(prop(n).process)
                    opt=[' -process ',h.addPathQuote(prop(n).process)];
                    optstat=[' (',prop(n).process,')'];
                else
                    opt='';
                    optstat='';
                end

                cmd=[cmd,'project set ',h.addPathQuote(prop(n).name)...
                ,' ',prop(n).value,opt,char(10)];
                status=[status,formatDispStr(...
                [prop(n).name,' = ',prop(n).value,optstat],3)];
            end
        end

        function[status,cmd]=runProcess(h,process)
            switch process
            case 'compile'
                processTcl='"Check Syntax"';
            case 'synthesize'
                processTcl='"Synthesize - XST"';
            case 'translate'
                processTcl='"Translate"';
            case 'map'
                processTcl='"Map"';
            case 'par'
                processTcl='"Place & Route"';
            case 'implement'
                processTcl='"Implement Design"';
            case 'generatebit'
                processTcl='"Generate Programming File"';
            otherwise
                error(message('EDALink:TclTM:TclTM:undefinedprocess'));
            end

            cmd=['process run ',processTcl,char(10)];
            status=formatDispStr(['Running ',processTcl],1);
        end



        function cmd=searchCommand(h,searchtype,varargin)
            if nargin<3
                searchobj='*.*';
            else
                searchobj=varargin{1};
            end
            cmd=['search ',searchobj,' -type ',searchtype];
        end

        function cmd=getPropCommand(h,prop)
            if~isempty(prop.process)
                opt=[' -process ',prop.process];
            else
                opt='';
            end
            cmd=['project get ',prop.name,opt];
        end



        function[status,cmd]=setTargetDevice(h,target)
            prop=struct('name',{'family','device','speed','package'},...
            'value',{target.family,target.device,target.speed,target.package},...
            'process','');
            [status,cmd]=h.setProp(prop);
        end

        function[status,cmd]=newProject(h,name,loc,target,projPath)

            proj=[name,'.xise'];
            cmd=['project new ',proj,char(10)];

            [~,c]=h.setTargetDevice(target);
            cmd=[cmd,c];

            familyDisp=getFPGAPartList(target.family,'customerName');
            if nargin<5
                projDisp=fullfile(loc,proj);
            else
                projDisp=h.getProjectLink(projPath);
            end

            status=[...
            formatDispStr('Project Location:',2)...
            ,formatDispStr(projDisp,3)...
            ,formatDispStr('Target Device:',2)...
            ,formatDispStr(...
            [familyDisp,' ',target.device,target.speed,target.package],3)];
        end

        function[status,cmd]=getTargetDevice(h,varname)
            prop=struct('name',{'family','device','speed','package'},...
            'process','');
            cmd='';
            for n=1:length(prop)
                c=h.getPropCommand(prop(n));
                [~,c]=h.writeFile(varname,c);
                cmd=[cmd,c];
            end

            status='';
        end

        function[status,cmd]=getProjectFiles(h,varname)












            searchvar='projfile';
            cmd=h.searchCommand('file');
            [~,cmd]=h.setVar(searchvar,cmd);

            collectvar='obj';
            subcmd=['object name $',collectvar];
            [~,subcmd]=h.writeFile(varname,subcmd);
            subcmd(end)='';

            c=['collection foreach ',collectvar,' $',searchvar...
            ,' { ',subcmd,' }',char(10)];
            cmd=[cmd,c];


            status='';
        end



















        function newstr=addPathQuote(h,str)

            newstr=str;
            if strfind(newstr,' ')
                if~strcmp(newstr(1),'"')
                    newstr=['"',newstr];
                end
                if~strcmp(newstr(end),'"')
                    newstr=[newstr,'"'];
                end
            end
        end

        function link=getProjectLink(h,projectPath)


            if feature('hotlinks')
                iseTool='ise';
                cmd=['system([''',iseTool,' '' char(34) '''...
                ,projectPath,''' char(34) char(38)]);'];
                link=['<a href="matlab:',cmd,'">',projectPath,'</a>'];
            else
                link=projectPath;
            end
        end

    end

end
