function entitysigs=createInputOutputPorts(this,entitysigs)








    emitMode=isempty(pirNetworkForFilterComp);
    if~emitMode

        hN=pirNetworkForFilterComp;
    end

    inputall=hdlgetallfromsltype(this.inputSLtype,'inputport');
    inputsltype=inputall.portsltype;

    outputall=hdlgetallfromsltype(this.outputSLtype,'outputport');
    outputsltype=outputall.portsltype;

    numChannel=hdlgetparameter('filter_generate_multichannel');

    if hdlgetparameter('isvhdl')&&(numChannel>1)
        inputvtype=this.inputvectorvtype;
        outputvtype=this.outputvectorvtype;
    else
        inputvtype=inputall.portvtype;
        outputvtype=outputall.portvtype;
    end

    if emitMode
        if(numChannel==1)
            [~,entitysigs.input]=hdlnewsignal(hdlgetparameter('filter_input_name'),...
            'filter',-1,this.isInputPortComplex,0,inputvtype,inputsltype);
            hdladdinportsignal(entitysigs.input);

            [~,entitysigs.output]=hdlnewsignal(hdlgetparameter('filter_output_name'),...
            'filter',-1,this.isOutputPortComplex,0,outputvtype,outputsltype);
            hdladdoutportsignal(entitysigs.output);
        else
            if hdlgetparameter('isvhdl')&&(hdlgetparameter('ScalarizePorts')~=1)
                [~,ptr]=hdlnewsignal(hdlgetparameter('filter_input_name'),...
                'filter',-1,this.isInputPortComplex,[numChannel,0],inputvtype,inputsltype);
                hdladdinportsignal(ptr);
                ptr_vec=hdlexpandvectorsignal(ptr);
                entitysigs.input=ptr_vec;

                [~,ptr]=hdlnewsignal(hdlgetparameter('filter_output_name'),...
                'filter',-1,this.isOutputPortComplex,[numChannel,0],outputvtype,outputsltype);
                hdladdoutportsignal(ptr);
                ptr_vec=hdlexpandvectorsignal(ptr);
                entitysigs.output=ptr_vec;
            else
                for n=1:numChannel
                    [~,entitysigs.input(n)]=hdlnewsignal([hdlgetparameter('filter_input_name'),num2str(n)],...
                    'filter',-1,this.isInputPortComplex,0,inputvtype,inputsltype);
                    hdladdinportsignal(entitysigs.input(n));
                end

                for n=1:numChannel
                    [~,entitysigs.output(n)]=hdlnewsignal([hdlgetparameter('filter_output_name'),num2str(n)],...
                    'filter',-1,this.isOutputPortComplex,0,outputvtype,outputsltype);
                    hdladdoutportsignal(entitysigs.output(n));
                end
            end
        end
    else
        entitysigs.input=hN.PirInputSignals(1);
        entitysigs.output=hN.PirOutputSignals(1);
    end
