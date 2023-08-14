classdef BackAnnotator
    properties(GetAccess=private,SetAccess=private)
modelName
criticalPaths
gmPrefixOpt
successfullyHighlighted
    end

    methods

        function[this,debugStrings]=BackAnnotator(modelName,rootPIR,gmPrefixOpt,targetPlatform,pathToTimingFile)
            import BA.New.ReportParser.XilinxVivadoTvrParser;
            import BA.New.CP.Report2CP;

            debugStrings={};
            debugStrings{end+1}=sprintf('\nParsing the timing file: `%s`...\n',pathToTimingFile);

            if strcmp(targetPlatform,'Xilinx Vivado')
                report=XilinxVivadoTvrParser.parse(pathToTimingFile);
            else
                fprintf('ERORR: platform `%s` is not supported yet...',targetPlatform);
                this=-1;
                return;
            end
            [this.criticalPaths,ds]=Report2CP.parse(rootPIR,gmPrefixOpt,report);
            debugStrings=horzcat(debugStrings,ds);
            this.gmPrefixOpt=gmPrefixOpt;

            this.modelName=modelName;
            this.successfullyHighlighted={};

            debugStrings{end+1}=sprintf('\nThere are `%d` unique paths...',length(this.criticalPaths));
        end

        function[this,table,debugStrings]=annotate(this,numCP)
            import BA.New.BackAnnotator;
            debugStrings={};
            table={};
            if length(this.criticalPaths)<numCP
                fprintf('ERROR: the provided `numCP = %d` is greater than the number of paths in the model\n',numCP);
                return;
            end

            criticalPath=this.criticalPaths(numCP);
            [table,this.successfullyHighlighted,debugStrings]=BackAnnotator.handleCriticalPath(this.gmPrefixOpt,criticalPath);
        end

        function this=reset(this)
            import BA.New.Util;


            Util.forEach(@(path)hilite_system(path,'none'),this.successfullyHighlighted);

            this.criticalPaths=[];
            this.gmPrefixOpt='';
            this.successfullyHighlighted=[];
        end





















































    end


    methods(Static,Access=private)

        function[table,debugStrings]=newReporting(gmPrefix,abstractComponents,acPathToTVRName,acPathToComponent,acPathToDelay,acPathToHighlightSuccess,bestpath)
            import BA.New.Util;



            table=cell(length(bestpath)+1,4);

            table{1,1}='TVR Name';
            table{1,2}='Simulink Path';
            table{1,3}='Delay (ns)';
            table{1,4}='Highlight Successful?';

            for i=1:length(bestpath)
                path=[gmPrefix,bestpath{i}];

                if acPathToComponent.isKey(path)
                    reportFileName=acPathToTVRName(path);
                    ac=acPathToComponent(path);
                    delay=acPathToDelay(path);

                    table{i+1,1}=reportFileName;
                    table{i+1,2}=[gmPrefix,Util.componentPath(ac)];
                    table{i+1,3}=sprintf('%.4f',delay);
                    table{i+1,4}=Util.ifElse(acPathToHighlightSuccess(path),@()'true',@()'false');
                else
                    table{i+1,1}='-';
                    table{i+1,2}=[path];
                    table{i+1,3}='-';
                    table{i+1,4}=Util.ifElse(acPathToHighlightSuccess(path),@()'true',@()'false');
                end
            end

            debugStrings={Util.asTableStr(table)};
        end





        function[table,successfulPaths,debugStrings]=handleCriticalPath(gmPrefixOpt,criticalPath)
            import BA.New.Util;
            import BA.New.BackAnnotator;
            import BA.New.Optional;

            gmPrefix=gmPrefixOpt.unwrapOr('');

            components=criticalPath.getComponents();
            if isempty(components)
                table={};
                successfulPaths={};
                debugStrings={};
                return;
            end


            absSource=components(1);
            absDest=components(end);


            acPaths=Util.map(@(ac)ac.getFullPath(),components);
            acComponents=Util.map(@(ac)ac.getSLComponent(),components);
            acDelays=Util.map(@(ac)ac.getDelay(),components);
            acTVRNames=Util.map(@(ac)ac.getTVRName(),components);
            acHighlightSuccess=false(1,length(acPaths));

            acPathToComponent=containers.Map(acPaths,acComponents);
            acPathToDelay=containers.Map(acPaths,acDelays);
            acPathToHighlightSuccess=containers.Map(acPaths,acHighlightSuccess);
            acPathToTVRName=containers.Map(acPaths,acTVRNames);
            clear acComponents acDelays acHighlightSuccess acPaths acTVRNames;


            bestpath=Util.approximateCP(...
            Util.map(@(ac)ac.getSLComponent(),components)...
            );


            for i=1:length(bestpath)
                node=[gmPrefix,bestpath{length(bestpath)-i+1}];
                [success,ds]=Util.highlight_with_path(Optional.none(),node);
                acPathToHighlightSuccess(node)=success;
            end




            [table,debugStrings]=BackAnnotator.newReporting(...
            gmPrefix,...
            components,...
            acPathToTVRName,...
            acPathToComponent,...
            acPathToDelay,...
            acPathToHighlightSuccess,...
bestpath...
            );

            successfulPaths=Util.filter(@(k)acPathToHighlightSuccess(k),keys(acPathToHighlightSuccess));
            successfulPaths=Util.map(@(path)[gmPrefixOpt.unwrapOr(''),path],successfulPaths);
        end

    end
end
