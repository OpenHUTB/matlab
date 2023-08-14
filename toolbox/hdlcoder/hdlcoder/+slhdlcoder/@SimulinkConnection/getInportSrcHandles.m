function inportHandles=getInportSrcHandles(this)






    hSubsystem=get_param(this.System,'handle');


    phan=get_param(hSubsystem,'PortHandles');
    inportHandleArray=zeros(1,length(phan.Inport));
    for m=1:length(phan.Inport)
        inportHandleArray(m)=this.getSrcBlkOutportHandle(hSubsystem,m);
    end


    inportHandles=unique(inportHandleArray);

end
