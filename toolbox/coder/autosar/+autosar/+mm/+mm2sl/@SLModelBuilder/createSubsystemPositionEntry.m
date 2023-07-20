




function createSubsystemPositionEntry(self,currSS)



    currSS=autosar.mm.mm2sl.SLModelBuilder.getHandle(currSS);
    blocks=find_system(currSS,'SearchDepth',1,'type','block');
    blocks(blocks==currSS)=[];



    maxX=50;
    maxY=10;
    numInp=0;
    numOutp=0;
    numSs=0;
    numTrigp=0;
    for ii=1:numel(blocks)
        pos=get_param(blocks(ii),'Position');
        maxX=max(maxX,pos(3));
        maxY=max(maxY,pos(4));
        switch lower(get_param(blocks(ii),'BlockType'))
        case 'inport'
            numInp=numInp+1;
        case 'outport'
            numOutp=numOutp+1;
        case 'subsystem'
            numSs=numSs+1;
        case 'triggerport'
            numTrigp=numTrigp+1;
        otherwise

        end
    end


    block2PositionMap=containers.Map();
    block2PositionMap('Inport')=[50,maxY,25,30,13,numInp];
    block2PositionMap('Outport')=[max(600,maxX),maxY,25,30,13,numOutp];
    block2PositionMap('SubSystem')=[240,(maxY-110),160,200,100,numSs];
    block2PositionMap('TriggerPort')=[max(335,maxX),0,10,10,10,numTrigp];
    block2PositionMap('MySelf')=[max(600,maxX),maxY];


    self.slSubsystem2PositionMap(currSS)=block2PositionMap;

end


