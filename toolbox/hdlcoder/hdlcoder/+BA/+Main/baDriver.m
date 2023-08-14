



classdef baDriver<handle
    properties(SetAccess=private,GetAccess=private)
CP_IR
annotationStrategy
ip
rootNode
modelName


        unique=false
        showdelays=true
        skipannotation=false;
        showends=true
        showall=false
        reset=false
        endsonly=false
        targetPlatform='Xilinx ISE'
        targetModel='Original'
        externalParser=[]

    end

    methods

        function printOriginalCP(thisBA)
            disp('Critical Paths:');

            thisBA.CP_IR.printOriginalCP;
        end


        function out=printAbstractCP(thisBA)
            disp('Critical Paths:');

            thisBA.CP_IR.printAbstractCP;
            out=thisBA.CP_IR;
        end


        function resetlast(thisBA)
            thisBA.CP_IR.reset;
        end


        function resetall(thisBA)
            thisBA.CP_IR.resetall;
        end


        function printColoredObjects(thisBA)
            thisBA.CP_IR.printColoredObjects;
        end


        function rn=getRootNode(thisBA)
            rn=thisBA.rootNode;
        end


        function mn=getModelName(thisBA)
            mn=thisBA.modelName;
        end



        function out=annotatePath(thisBA,varargin)
            out={};
            if strcmp(varargin{1},'reset')
                thisBA.resetall;
                return;
            end
            if strcmp(varargin{1},'printAbstractCP')
                out=thisBA.printAbstractCP;
                return;
            end
            if strcmp(varargin{1},'printOriginalCP')
                thisBA.printOriginalCP;
                return;
            end
            if strcmp(varargin{1},'printColoredObjects')
                thisBA.printColoredObjects;
                return;
            end
            if isnan(varargin{1})
                error(message('hdlcoder:backannotate:NotValidOption'));
            end
            cpnum=0;
            if~isempty(varargin)
                cpnum=varargin{1};
            end
            if isempty(thisBA.annotationStrategy)
                if strncmpi(thisBA.targetPlatform,'Altera',6)
                    thisBA.annotationStrategy=BA.Algorithm.pirInterpolationWithBlkTypesStrategy;
                else
                    thisBA.annotationStrategy=BA.Algorithm.pirInterpolationStrategy;
                end

                thisBA.CP_IR.setStrategy(thisBA.annotationStrategy);
            end


            thisBA.CP_IR.annotatePath(cpnum,thisBA.modelName,thisBA.unique,thisBA.showdelays,thisBA.showall,thisBA.showends,thisBA.endsonly,thisBA.skipannotation,thisBA.targetModel);

        end



        function setparameters(thisBA,varargin)

            thisBA.ip.parse(varargin{:});


            params=thisBA.ip.Results;


            thisBA.unique=strcmpi(params.unique,'on');
            thisBA.showall=strcmpi(params.showall,'on');
            thisBA.reset=strcmpi(params.reset,'on');
            thisBA.endsonly=strcmpi(params.endsonly,'on');
            thisBA.showends=strcmpi(params.showends,'on');
            thisBA.showdelays=strcmpi(params.showdelays,'on');
            thisBA.skipannotation=strcmpi(params.skipannotation,'on');
            thisBA.targetPlatform=params.targetPlatform;
            thisBA.targetModel=params.targetModel;
            thisBA.externalParser=params.externalparser;
        end


        function thisBA=baDriver(mdl,timingFile,varargin)

            thisBA.modelName=mdl;

            thisBA.ip=inputParser;
            thisBA.ip.addParamValue('unique','off',@isOnOrOff);
            thisBA.ip.addParamValue('showall','off',@isOnOrOff);
            thisBA.ip.addParamValue('reset','off',@isOnOrOff);
            thisBA.ip.addParamValue('endsonly','off',@isOnOrOff);
            thisBA.ip.addParamValue('showends','on',@isOnOrOff);
            thisBA.ip.addParamValue('showdelays','on',@isOnOrOff);
            thisBA.ip.addParamValue('skipannotation','off',@isOnOrOff);
            thisBA.ip.addParamValue('targetPlatform','Xilinx');
            thisBA.ip.addParamValue('targetModel','Original');
            thisBA.ip.addParamValue('externalparser',[]);


            thisBA.setparameters(varargin{:});


            p=pir;
            if isempty(p)
                error(message('hdlcoder:backannotate:ModelNotReady'));
            end


            pirRootNode=p.getTopNetwork.Name;
            thisBA.rootNode=pirRootNode;


            if~isempty(thisBA.externalParser)
                thisBA.targetPlatform='External';
            end

            fprintf(1,'### Parsing the timing file...\n');

            if strcmpi(thisBA.targetPlatform,'Xilinx Vivado')

                xilinxVivadoFactory=BA.Parser.XilinxVivadoFactory;

                hdrive=hdlmodeldriver(thisBA.getModelName);

                thisBA.CP_IR=xilinxVivadoFactory.makeCP_IR(timingFile,(hdrive.getParameter('LatencyConstraint')>0));
            elseif strncmpi(thisBA.targetPlatform,'Xilinx',6)

                xilinxFactory=BA.Parser.XilinxFactory;

                hdrive=hdlmodeldriver(thisBA.getModelName);

                thisBA.CP_IR=xilinxFactory.makeCP_IR(timingFile,(hdrive.getParameter('LatencyConstraint')>0));
            elseif strncmpi(thisBA.targetPlatform,'Altera',6)


                alteraFactory=BA.Parser.AlteraFactory;


                thisBA.CP_IR=alteraFactory.makeCP_IR(timingFile);
            else


                thisBA.CP_IR=thisBA.externalParser;
            end

        end

    end

    methods(Static)



        function flattenedName=flattenHierarchicalNames(name,target)
            if nargin<2
                target='Xilinx ISE';
            end
            if strncmpi(target,'Altera',6)
                pathsep='|';
            else
                pathsep='/';
            end
            flattenedName={};
            rest=name;
            i=1;
            while~isempty(rest)
                [flattenedName{i},rest]=strtok(rest,pathsep);%#ok<STTOK,AGROW>
                i=i+1;
            end

            if strncmpi(target,'Altera',6)
                flattenedName=BA.Main.baDriver.resolveHierarchicalNames(flattenedName);
            end





        end




        function flattenedName=resolveHierarchicalNames(name)
            flattenedName={};
            for i=1:length(name)
                part=name{i};
                k=strfind(part,':');
                if~isempty(k)
                    part=part((k+1):length(part));
                end
                flattenedName{i}=part;%#ok<AGROW>
            end
        end


        function fp=getFullPath(identifier,target)
            if nargin<2
                target='Xilinx';
            end
            if strcmpi(target,'Altera')
                pathsep='|';
            else
                pathsep='/';
            end
            if ischar(identifier)
                fp=identifier;
            elseif iscell(identifier)

                fp=identifier{1};
                for i=2:numel(identifier)
                    fp=[fp,pathsep,identifier{i}];%#ok<AGROW>
                end
            else

                fp=[identifier.Owner.FullPath,pathsep,identifier.Name];
            end
        end


    end

end

function valid=isOnOrOff(input)
    valid=strcmpi(input,'on')||strcmpi(input,'off');
end



