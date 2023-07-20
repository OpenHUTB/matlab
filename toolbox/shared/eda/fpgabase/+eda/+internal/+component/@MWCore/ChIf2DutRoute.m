function ChIf2DutRoute(this,input)




    endingBit=0;
    byteAlign=true;
    for i=1:length(input)
        dataWidth=input{i}.width;
        startingBit=endingBit+dataWidth-1;
        if input{i}.width==1
            this.assign(['bitsliceget(dut_din, ',num2str(startingBit),')'],input{i}.handle);
        else
            this.assign(['bitsliceget(dut_din, ',num2str(startingBit),',',num2str(endingBit),')'],input{i}.handle);
        end
        if~byteAlign
            endingBit=startingBit+1;
        else
            if mod(dataWidth,8)==0
                dataBytes=floor(dataWidth/8);
            else
                dataBytes=floor(dataWidth/8)+1;
            end
            endingBit=endingBit+dataBytes*8;
        end
    end
end