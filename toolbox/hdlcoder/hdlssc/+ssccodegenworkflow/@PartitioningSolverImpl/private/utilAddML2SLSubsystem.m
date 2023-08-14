function[hMLFB,MlBlkInfo]=utilAddML2SLSubsystem(parent,code,position,dataType,...
    argDims,sampleTime,latencyStrategy,hasQs)









    fcnName=getFcnName(code);


    hMLFB=utilAddSubsystem(parent,fcnName,position);


    FID=fopen([fcnName,'.m'],'w');



    if strcmp(dataType,'single')
        code=regexprep(code,{'double'},{'single'});
    end


    fprintf(FID,'%s',code);
    fclose(FID);


    args=createArgs(argDims,dataType,hasQs);


    fpConfig=hdlcoder.createFloatingPointTargetConfig('NativeFloatingPoint','LatencyStrategy',latencyStrategy);


    MlBlkInfo=calculateMLLatencyResource1(fcnName,args,fpConfig,dataType);




    if strcmp(dataType,'single')
        report=codegen(fcnName,'-singleC','-args',args,'-config:mex','-silent');
    else
        report=codegen(fcnName,'-args',args,'-config:mex','-silent');
    end

    inferenceReport=report.inference;


    [gp,globalContext,settings]=setupPIR(fcnName,sampleTime);



    [hFunctionNIC,failed]=internal.ml2pir.mlhdlc.createPIRfromML(fcnName,inferenceReport,settings{:});


    if failed
        me=MException('generateImplementationModel:ML2PIRfailure');
        throwAsCaller(me);
    end

    gp.setTopNetwork(hFunctionNIC.ReferenceNetwork);


    outfile=utilDrawPIR(gp,globalContext);






    Simulink.BlockDiagram.copyContentsToSubsystem(outfile,[parent,'/',fcnName])


    bdclose(outfile);


    fModechart=matlab.internal.feature("SSC2HDLModechart");

    if(fModechart)

        nameList={'x','u','t','m','q','ci'};
        for i=1:numel(nameList)
            name=nameList{i};
            inPort=Simulink.findBlocksOfType([parent,'/',fcnName],'Inport','Name',name);
            if~isempty(inPort)
                if isempty(get_param(inPort,'PortConnectivity').DstBlock)

                    hTerm=add_block('hdlsllib/Sinks/Terminator',[parent,'/',fcnName,'/term'],...
                    'MakeNameUnique','on',...
                    'Position',[935,130,955,150]);

                    add_line([parent,'/',fcnName],strcat(name,'/1'),strcat(get_param(hTerm,'Name'),'/1'),...
                    'autorouting','on');
                end
            end
        end
    else

        nameList={'x','u','t','m'};
        for i=1:numel(argDims)
            name=nameList{i};
            inPort=[parent,'/',fcnName,'/',name];
            if isempty(get_param(inPort,'PortConnectivity').DstBlock)

                hTerm=add_block('hdlsllib/Sinks/Terminator',[parent,'/',fcnName,'/term'],...
                'MakeNameUnique','on',...
                'Position',[935,130,955,150]);

                add_line([parent,'/',fcnName],strcat(name,'/1'),strcat(get_param(hTerm,'Name'),'/1'),...
                'autorouting','on');
            end
        end
    end




    Simulink.BlockDiagram.arrangeSystem([parent,'/',fcnName],'FullLayout','True','Animation','False')

end


function[gp,globalContext,settings]=setupPIR(fcnName,sampleTime)

    p=pir;
    p.destroy;
    gp=pir(fcnName);
    globalContext=pir;


    hTopNetwork=gp.addNetwork;
    hTopNetwork.Name=fcnName;
    gp.setTopNetwork(hTopNetwork);













    slRate=sampleTime;
    settings={...
...
    'ParentNetwork',hTopNetwork,...
...
...
...
    'UserComments',false,...
...
...
...
    'InstantiateFunctions',false,...
...
    'SLRate',slRate};
end

function name=getFcnName(code)
    [begin,~]=strtok(code,'(');
    name=extractAfter(begin,'= ');
end

function args=createArgs(argDims,dataType,hasQs)

    fModechart=matlab.internal.feature("SSC2HDLModechart");

    args=cell(size(argDims));
    for i=1:numel(argDims)
        if i==4
            if(~fModechart||~hasQs)||(fModechart&&hasQs&&numel(argDims)==6)
                featIntModes=matlab.internal.feature("SSC2HDLIntegerModes");
                if(featIntModes)
                    args{i}=cast(ones(argDims{i}),'int32');
                else
                    args{i}=cast(ones(argDims{i}),'logical');
                end
            else
                args{i}=cast(ones(argDims{i}),dataType);
            end
        else
            args{i}=cast(ones(argDims{i}),dataType);
        end
    end

end

