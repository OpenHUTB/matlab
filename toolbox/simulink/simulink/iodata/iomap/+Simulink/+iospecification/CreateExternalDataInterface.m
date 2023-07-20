classdef CreateExternalDataInterface<handle





    methods(Abstract)

        setBlockParams(obj,blockPathToBeCreated,isModelCompiled)
    end




    methods


        function[boolOut,err]=copyAndConnect(obj,model,isModelCompiled,blockPathToBeCreated,portNumber)

            [boolCopy,err]=createACopy(obj,blockPathToBeCreated,isModelCompiled,portNumber);

            if~boolCopy
                boolOut=false;
                return;
            end

            splitBlockPath=strsplit(blockPathToBeCreated,'/');
            copyToModel=splitBlockPath{1};
            inport_name=[copyToModel,'/In',num2str(portNumber)];

            outport_name=sprintf('%s/Out%d',copyToModel,portNumber);

            [boolConnect,err]=createAndConnectOutport(obj,copyToModel,inport_name,outport_name);

            if~boolConnect
                boolOut=false;
                return;
            end

            boolOut=true;

        end



        function[boolOut,err]=createACopy(obj,blockPathToBeCreated,isModelCompiled,portNumber)

            boolOut=false;
            err=[];
            try


                newPath=getPathOfNewPortToCreate(obj,blockPathToBeCreated,portNumber);
                create(obj,newPath);
            catch ME
                err=ME;
                return;
            end
            setBlockParams(obj,newPath,isModelCompiled);

            boolOut=true;

        end


        function[bool,err]=createAndConnectOutport(obj,model,inport_name,outport_name)


            bool=false;
            err=[];
            try
                createOutport(obj,outport_name);
                decorateOutportSettings(obj,outport_name);
                connectInportToOutport(obj,model,inport_name,outport_name);
            catch ME
                err=ME;
                return;
            end
            bool=true;
        end


        function create(~,blockPathToBeCreated)
            add_block('built-in/Inport',blockPathToBeCreated);
        end


        function createOutport(~,outport_name)
            add_block('built-in/Outport',outport_name);
        end


        function connectInportToOutport(obj,model,inport_name,outport_name)

            inport_name=strsplit(inport_name,'/');
            inport_name=inport_name{end};
            outport_name=strsplit(outport_name,'/');
            outport_name=outport_name{end};

            start_point=[inport_name,'/1'];
            end_point=[outport_name,'/1'];
            add_line(model,start_point,end_point);
        end


        function decorateOutportSettings(obj,outport)


        end


        function newPath=getPathOfNewPortToCreate(obj,blockPathToBeCreated,portNumber)
            pathSplit=strsplit(blockPathToBeCreated,'/');
            newPath=[pathSplit{1},'/In',num2str(portNumber)];
        end
    end


end
