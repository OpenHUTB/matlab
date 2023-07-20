classdef(Hidden=true)Launcher<rtw.connectivity.Launcher





    properties(SetAccess='private',GetAccess='private')

        stackProfileReportEnabled=true;
    end

    methods
        function this=Launcher(componentArgs,...
            builder)
            narginchk(2,2);


            this@rtw.connectivity.Launcher(componentArgs,builder);
        end


        function linkObject=getLinkObject(this)
            linkObject=this.getBuilder.getLinkObject;
        end

        function isMake=isMakeFile(this)
            isMake=isa(this.getLinkObject(),'linkfoundation.xmakefile.XMakefile');
        end



        function startApplication(this)
            narginchk(1,1);

            applicationToLoad=this.getBuilder.getApplicationExecutable;
            if~this.isMakeFile
                this.loadApplication(applicationToLoad);

                this.startApplicationPause;
                this.runApplication;
            else








                this.runApplication;
                this.startApplicationPause;
            end
        end


        function stopApplication(this)
            narginchk(1,1);
            if(this.isMakeFile())



            else
                linkObject=this.getLinkObject;

                linkObject.halt;

                if this.stackProfileReportEnabled
                    this.reportStackProfile(linkObject);
                end
            end
        end

        function setStackProfileReportingEnabled(this,stackProfileReportEnabled)
            this.stackProfileReportEnabled=stackProfileReportEnabled;
        end
    end

    methods(Access='protected')
        function loadApplication(this,applicationToLoad)
            linkObject=this.getLinkObject;
            linkObject.reset;
            linkObject.load(applicationToLoad);

            if this.stackProfileReportEnabled
                stackProfilePilOutput=linkObject.profile('stack','setup','internalUseFlag');
                if ispref('Embedded_IDE_Link_Testing')&&ispref('Embedded_IDE_Link_Testing','Get_Stack_Profile_PIL_Output')
                    assignin('base','stackProfilePilSetupOutput',stackProfilePilOutput);
                end
            end
        end

        function runApplication(this)
            try
                linkObject=this.getLinkObject;
                curfolder=cd(this.getComponentArgs.getApplicationCodePath);
                linkObject.run('run');
                cd(curfolder);
            catch ex
                cd(curfolder);
                rethrow(ex);
            end
        end
    end

    methods(Access='private')
        function reportStackProfile(~,linkObject)

            infos=linkObject.profile('stack','report','internalUseFlag');
            [stackProfilePilOutput,outputCmd]=linkObject.getStackProfileReportOutput(infos);

            if ispref('Embedded_IDE_Link_Testing')&&ispref('Embedded_IDE_Link_Testing','Get_Stack_Profile_PIL_Output')
                assignin('base','stackProfilePilOutput',stackProfilePilOutput);
            end

            hyperlinkContents=[...
            '------------------------------------------------------------------\n',...
'PIL Test Framework Overhead:\n'...
            ,'------------------------------------------------------------------\n',...
'The maximum stack usage reported after PIL is the stack usage of  \n'...
            ,'the entire PIL application, which includes a small amount of stack\n'...
            ,'used by the PIL test framework. The stack usage reported is therefore\n'...
            ,'a maximum bound on the stack usage of the algorithm under test.   \n\n'...
            ,'To more accurately determine the stack usage of the algorithm it  \n'...
            ,'is possible to use the stack profiling feature on an application  \n'...
            ,'that is not configured for PIL. This will allow the stack usage to\n'...
            ,'be determined without the stack overhead of the PIL test framework.\n'...
            ,'Please see the documentation for details.\n'...
            ,'------------------------------------------------------------------\n'];

















            overhead=targets_hyperlink_manager('new','including the PIL test framework overhead',...
            ['disp(sprintf(''',hyperlinkContents,'''))']);

            disp(['Maximum stack usage during PIL (',overhead,'):']);
            disp(' ');
            for i=1:length(infos)
                profInfoObj=infos(i);
                disp([profInfoObj.memoryBuffer.name,': '...
                ,num2str(profInfoObj.wordsUsed),'/'...
                ,num2str(profInfoObj.memoryLength),' (',num2str(profInfoObj.percentageUse),'%) MAUs used.']);

                if(profInfoObj.memoryLength-profInfoObj.wordsUsed)<=0
                    memBuffer=profInfoObj.memoryBuffer;
                    warndlg(['"',memBuffer.name,'" may have overflowed!'...
                    ,sprintf('\n\n'),'See the report in the MATLAB command window '...
                    ,'for more details.'],...
                    'Stack Overflow Warning');
                end
            end
            disp(' ');
            disp(sprintf(outputCmd));%#ok<DSPS>
            disp(' ');
        end
    end
end
