
function portsNewWidth=upgradeWidth(~,portsNums,portsDims,portsOldWidth)




    portsNewWidth=cell(1,portsNums);
    for i=1:portsNums
        portDim=portsDims{i};



        if(portDim>1)
            portsNewWidth{i}=hdlturnkey.data.upgradeWidthToPowerOfTwo(portsOldWidth{i});
        else
            portsNewWidth{i}=portsOldWidth{i};
        end
    end
end
