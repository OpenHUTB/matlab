function svgString=process_port_label(obj,args)



    label='';
    portNumber='';



    startAdditional=4;
    svgString='';






    if(ischar(args{2}))
        label=args{2};
        startAdditional=3;



    else
        if(isnumeric(args{2}))
            portNumber=args{2};
            label=args{3};
        end
    end

    portName='';


    if(strcmpi(args{1},'input'))
        portName='L';
    end
    if(strcmpi(args{1},'output'))
        portName='R';
    end
    if(strcmpi(args{1},'lconn'))
        portName='L';
    end
    if(strcmpi(args{1},'rconn'))
        portName='R';
    end
    if(strcmpi(args{1},'enable'))
        portName='T';
    end
    if(strcmpi(args{1},'trigger'))
        portName='T';
    end
    if(strcmpi(args{1},'action'))
        portName='T';
    end



    if(isempty(portNumber))
        if(strcmp(portName,'T'))
            portNumber=obj.TopLabelCount;
            obj.TopLabelCount=obj.TopLabelCount+1;
        end
        if(strcmp(portName,'B'))
            portNumber=obj.BottomLabelCount;
            obj.BottomLabelCount=obj.BottomLabelCount+1;
        end
        if(strcmp(portName,'L'))
            portNumber=obj.InputLabelCount;
            obj.InputLabelCount=obj.InputLabelCount+1;
        end
        if(strcmp(portName,'R'))
            portNumber=obj.OutputLabelCount;
            obj.OutputLabelCount=obj.OutputLabelCount+1;
        end
    else

        if(strcmpi(args{1},'lconn'))
            portNumber=portNumber+obj.LConnCount-1;
        elseif(strcmpi(args{1},'rconn'))
            portNumber=portNumber+obj.RConnCount-1;
        else
            portNumber=portNumber-1;
        end
    end


    portName=[portName,string(portNumber)];

    tagToUse='text';

    if(length(args)>4&&strcmp(args{startAdditional},'texmode')&&strcmp(args{startAdditional+1},'on'))
        label=Simulink.Mask.cleanMath(string(label));
        label=['$',label,'$'];
        tagToUse='math';
    end


    if(isempty(obj.ColorValue))
        svgString=[svgString,'<',tagToUse,' x="0" y="0" class="dvg-port-label" d:options="Port:',portName,'">',label,'</',tagToUse,'>'];
    else
        svgString=[svgString,'<',tagToUse,' x="0" y="0" class="dvg-port-label" d:options="Port:',portName,'" style="fill:',string(obj.ColorValue),'">',label,'</',tagToUse,'>'];
    end
    svgString=strjoin(string(svgString),'');
end