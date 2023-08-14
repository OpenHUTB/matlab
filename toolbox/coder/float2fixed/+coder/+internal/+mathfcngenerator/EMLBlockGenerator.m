







classdef EMLBlockGenerator<handle

    methods(Static,Access=public)



        function generate(mfFcnName,script)
            if~license('test','SIMULINK')
                error('Simulink License not available - cannot export MATLAB code into a MATLAB function block')
            end
            load_system('eml_lib');

            mfMdlHandle=new_system(['untitled_',mfFcnName]);
            mfMdlName=get_param(mfMdlHandle,'Name');

            open_system(mfMdlName);

            mfHandle=add_block('eml_lib/MATLAB Function',[mfMdlName,'/',mfFcnName],'MakeNameUnique','on');
            mfBlkName=get_param(mfHandle,'Name');
            mfBlkPath=[mfMdlName,'/',mfBlkName];

            r=sfroot;
            m=r.find('-isa','Stateflow.Machine','Name',mfMdlName);
            c=m.find('-isa','Stateflow.EMChart','Path',mfBlkPath);
            d=c.find('-isa','Stateflow.Data');


            arrayfun(@delete,d)

            c.InputFimath='hdlfimath';
            c.TreatAsFi='Fixed-point & Integer';


            numInPorts=0;
            numOutPorts=0;

            mt=mtree(script);
            funcNode=mt.root;
            [inPortNames,outPortNames]=coder.internal.MTREEUtils.getFcnInputOutputParamNames(mfFcnName,funcNode);

            initFcnStr='';

            for ii=1:length(inPortNames)
                d=Stateflow.Data(c);
                d.Name=inPortNames{ii};


                d.Scope='Input';
                numInPorts=numInPorts+1;
                d.DataType='Double';
                d.Props.Type.Expression='Double';

            end

            for ii=1:length(outPortNames)
                d=Stateflow.Data(c);
                d.Name=outPortNames{ii};
                d.Scope='Output';
                numOutPorts=numOutPorts+1;
            end


            c.Script=script;


            set_param(mfMdlName,'initFcn',initFcnStr);

            inPortHandles=zeros(1,numInPorts);
            for i=1:numInPorts
                slHandle=add_block('built-in/Inport',[mfMdlName,'/in',num2str(i)],'MakeNameUnique','on');
                inPortHandles(i)=slHandle;
            end
            outPortHandles=zeros(1,numOutPorts);
            for i=1:numOutPorts
                slHandle=add_block('built-in/Outport',[mfMdlName,'/out',num2str(i)],'MakeNameUnique','on');
                outPortHandles(i)=slHandle;
            end

            coder.internal.mathfcngenerator.EMLBlockGenerator.formatBlockWithPorts(inPortHandles,outPortHandles,mfHandle);
        end


        function formatBlockWithPorts(inPorts,outPorts,bH)

            numInPorts=length(inPorts);
            numOutPorts=length(outPorts);

            height=max(numInPorts,numOutPorts)*60;
            width=70;
            origPos=[105,40,105+width,40+height];
            set_param(bH,'Position',origPos);

            inPortSpacer=height/(numInPorts+1);
            inOrigPos=[origPos(1)-70,origPos(2)+inPortSpacer-20/2];
            for i=1:numInPorts
                left=inOrigPos(1);top=inOrigPos(2)+(i-1)*inPortSpacer;right=left+20;bottom=top+20;
                set_param(inPorts(i),'Position',[left,top,right,bottom]);
                add_line(get_param(bH,'Parent'),[get_param(inPorts(i),'name'),'/1'],[get_param(bH,'Name'),'/',num2str(i)],'autorouting','on');
            end
            outPortSpacer=height/(numOutPorts+1);
            outOrigPos=[origPos(3)+70,origPos(2)+outPortSpacer-20/2];
            for i=1:numOutPorts
                left=outOrigPos(1);top=outOrigPos(2)+(i-1)*outPortSpacer;right=left+20;bottom=top+20;
                set_param(outPorts(i),'Position',[left,top,right,bottom]);
                add_line(get_param(bH,'Parent'),[get_param(bH,'Name'),'/',num2str(i)],[get_param(outPorts(i),'name'),'/1'],'autorouting','on');
            end
        end

    end
end
