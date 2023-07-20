function setSignalSrcDst(this,arg)






    argFields=fields(arg);
    for i=1:length(argFields)


        currentPort=this.ChildNode{end}.(argFields{i});
        if isa(currentPort,'eda.internal.component.Port')
            currentPort.signal=arg.(argFields{i});
            if isa(arg.(argFields{i}),'eda.internal.component.Signal')
                if(isa(currentPort,'eda.internal.component.Inport')||...
                    isa(currentPort,'eda.internal.component.ClockPort')||...
                    isa(currentPort,'eda.internal.component.ClockEnablePort')||...
                    isa(currentPort,'eda.internal.component.ResetPort'))
                    arg.(argFields{i}).Dst(end+1).Node=this.ChildNode{end};
                    arg.(argFields{i}).Dst(end).Port=this.ChildNode{end}.(cell2mat(argFields(i)));
                elseif isa(currentPort,'eda.internal.component.Outport')
                    arg.(argFields{i}).Src.Node=this.ChildNode{end};
                    arg.(argFields{i}).Src.Port=this.ChildNode{end}.(cell2mat(argFields(i)));

                end
            else

            end
        else
            this.ChildNode{end}.(argFields{i})=arg.(argFields{i});
        end
    end
end


