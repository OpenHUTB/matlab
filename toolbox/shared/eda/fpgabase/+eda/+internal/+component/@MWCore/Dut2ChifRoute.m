function Dut2ChifRoute(this,outPort,dut_dout,outDataWidthBits,actualOutDataWidth)
    byteAlign=true;
    str='bitconcat(';
    if~byteAlign
        zeroBits=outDataWidthBits-actualOutDataWidth;
        if zeroBits>0
            zeros=this.signal('Name','zeros','FiType',['std',num2str(zeroBits)]);
            this.assign(['fi(0,0, ',num2str(zeroBits),',0)'],zeros);
        end


        if zeroBits~=0
            str=[str,'zeros, '];
        end
        for i=length(outPort):-1:1
            str=[str,outPort{i}.Name,','];%#ok<*AGROW>
        end

    else
        zeroArrayIndex=1;
        for i=length(outPort):-1:1
            dataWidth=outPort{i}.width;
            if mod(dataWidth,8)==0
                dataBytes=floor(dataWidth/8);
            else
                dataBytes=floor(dataWidth/8)+1;
            end
            zeroBits=dataBytes*8-dataWidth;
            if zeroBits>0
                zeros(zeroArrayIndex)=this.signal('Name',['zeros_',num2str(zeroArrayIndex)],'FiType',['std',num2str(zeroBits)]);
                this.assign(['fi(0,0, ',num2str(zeroBits),',0)'],zeros(zeroArrayIndex));
                str=[str,[' zeros_',num2str(zeroArrayIndex)],', '];
                zeroArrayIndex=zeroArrayIndex+1;
            end
            str=[str,outPort{i}.handle.Name,','];
        end
    end

    str(end)=')';
    this.assign(str,dut_dout);
end
