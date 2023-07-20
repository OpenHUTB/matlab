function drawEMLBlock(this,emlBlockName,hC)



    load_system('eml_lib');

    slHandle=add_block('eml_lib/MATLAB Function',emlBlockName,'MakeNameUnique','on');
    hC.Name=get_param(slHandle,'Name');

    r=sfroot;
    m=r.find('-isa','Stateflow.Machine','Name',this.OutModelFile);
    c=m.find('-isa','Stateflow.EMChart','Path',emlBlockName);

    d=c.find('-isa','Stateflow.Data');


    for i=1:length(d)
        d(i).delete;
    end


    c.InputFimath='hdlfimath';
    c.TreatAsFi='Fixed-point & Integer';


    numInPorts=hC.NumberOfPirInputPorts('data');
    inPorts=hC.getInputPorts('data');

    for ii=1:numInPorts
        d=Stateflow.Data(c);
        d.Scope='Input';
        d.Name=inPorts(ii).Name;
        [sldt,sldtprops]=getslsignaltype(hC.getInputPortSignal(ii-1).Type);
        d.DataType='Expression';
        d.Props.Type.Expression=sldt.viadialog;
        d.Props.Array.Size=sldtprops.dimensionstr;
        if(sldtprops.iscomplex)
            d.props.Complexity='on';
        else
            d.props.Complexity='off';
        end
    end

    numOutPorts=hC.NumberOfPirOutputPorts('data');
    outPorts=hC.getOutputPorts('data');

    for ii=1:numOutPorts
        d=Stateflow.Data(c);
        d.Scope='Output';
        d.Name=outPorts(ii).Name;
        [sldt,sldtprops]=getslsignaltype(hC.getOutputPortSignal(ii-1).Type);
        d.DataType='Expression';
        d.Props.Type.Expression=sldt.viadialog;
        d.Props.Array.Size=sldtprops.dimensionstr;
        if(sldtprops.iscomplex)
            d.props.Complexity='on';
        else
            d.props.Complexity='off';
        end
    end

    params=hC.ParamInfo;
    numParams=numel(params);

    pList={};
    for ii=1:numParams
        pList{ii}=sprintf('p%d',this.getUniqueEmlParamNum);
    end

    for ii=1:numParams
        d=Stateflow.Data(c);
        d.Scope='Parameter';
        d.Name=pList{ii};
        d.Tunable=0;
        [sldt,sldtprops]=getslsignaltypefromval(params{ii});
        d.DataType='Expression';
        d.Props.Type.Expression=sldt.viadialog;
        d.Props.Array.Size=sldtprops.dimensionstr;
        if(sldtprops.iscomplex)
            d.props.Complexity='on';
        else
            d.props.Complexity='off';
        end
    end

    c.Script=getKernelScript(hC,pList);

    for ii=1:numParams

        ws=this.OutModelWorkSpace;
        ws.assignin(pList{ii},params{ii});



    end

end



function script=getKernelScript(hC,pList)



    numInPorts=hC.NumberOfPirInputPorts('data');
    numOutPorts=hC.NumberOfPirOutputPorts('data');
    numParams=numel(pList);

    inPortList='';
    for ii=1:numInPorts
        inPortList=[inPortList,sprintf('in%d, ',ii-1)];%#ok<*AGROW>
    end
    if~isempty(inPortList)
        inPortList(end-1:end)='';
    end

    outPortList='';
    for ii=1:numOutPorts
        outPortList=[outPortList,sprintf('out%d, ',ii-1)];
    end
    if~isempty(outPortList)
        outPortList(end-1:end)='';
    end

    paramPortList='';
    for ii=1:numParams
        paramPortList=[paramPortList,pList{ii},', '];
    end
    if~isempty(paramPortList)
        paramPortList(end-1:end)='';
    end

    sepStr='';
    if(numInPorts>0)&&(numParams>0)
        sepStr=', ';
    end

    if(hC.paramsFollowInputs)
        inputList=[inPortList,sepStr,paramPortList];
    else
        inputList=[paramPortList,sepStr,inPortList];
    end







    s1=sprintf('function [%s] = fcn(%s)\n',outPortList,inputList);
    s2=sprintf(' [%s] = %s(%s);',outPortList,hC.ipFileName,inputList);

    script=[s1,s2];

end

