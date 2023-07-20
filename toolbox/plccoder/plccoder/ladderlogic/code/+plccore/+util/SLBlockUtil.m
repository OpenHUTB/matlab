classdef SLBlockUtil


    methods(Static)
        function out=getPort(blkHandle,portType,portIndex)


            ports=get_param(blkHandle,'PortHandles');
            switch portType
            case{'output','Output','out'}
                out=ports.Outport(portIndex);
            case{'input','Input','in'}
                out=ports.Inport(portIndex);
            otherwise
                assert(false,'Invalid port type');
            end
        end

        function moveBlocktoPositionRelativetoPort(blkHdl,portHdl,campass,deltax)
            prtPos=get_param(portHdl,'Position');

            if nargin==3
                deltax=20;
            end




            dsInPos=get_param(blkHdl,'Position');


            len=dsInPos(3)-dsInPos(1);
            width=dsInPos(4)-dsInPos(2);
            switch campass
            case 'r'
                outNewPos=[prtPos(1)+deltax,...
                prtPos(2)-width/2,...
                prtPos(1)+len+deltax,...
                prtPos(2)+width/2];
            case 'l'
                outNewPos=[prtPos(1)-len-deltax,...
                prtPos(2)-width/2,...
                prtPos(1)-deltax,...
                prtPos(2)+width/2];
            case 'u'
                outNewPos=[prtPos(1)-len/2,...
                prtPos(2)-width-deltax,...
                prtPos(1)+len/2,...
                prtPos(2)-deltax];
            case 'd'
                outNewPos=[prtPos(1)-len/2,...
                prtPos(2)+deltax,...
                prtPos(1)+len/2,...
                prtPos(2)+width+deltax];
            otherwise
                assert(false,'Invalid location specified');
            end
            set_param(blkHdl,'Position',outNewPos);
        end

        function connectBlocks(parentBlock,outportHdls,inportHdls,align)





            if nargin==3
                align=false;
            end
















            for outindex=1:length(outportHdls)


                outport=outportHdls(outindex);


                for inindex=1:length(inportHdls)
                    inport=inportHdls(inindex);

                    add_line(parentBlock,outport,inport,'autorouting','on');

                    if align&&inindex==1

                        dstHdl=get_param(inport,'Parent');
                        srcPortPos=get_param(outport,'Position');
                        dstPortPos=get_param(inport,'Position');
                        dstPos=get_param(dstHdl,'Position');
                        ydiff=abs(dstPos(2)-dstPortPos(2));
                        dstPos(2)=srcPortPos(2)-ydiff;
                        ladderImportSimulink.utils.moveBlockTo(dstHdl,dstPos(1:2));




                        dstPorts=get_param(dstHdl,'PortHandles');
                        for ii=2:length(dstPorts.Inport)
                            inport=dstPorts.Inport(ii);

                            line=get_param(inport,'Line');
                            if line==-1
                                return;
                            end

                            srcPort=get_param(line,'Srcporthandle');
                            src=get_param(srcPort,'Parent');
                            ladderImportSimulink.utils.moveBlocktoPositionRelativetoPort...
                            (src,inport,'l');

                        end
                        for ii=2:length(dstPorts.Outport)
                            outport=dstPorts.Outport(ii);

                            line=get_param(outport,'Line');
                            if line==-1
                                return;
                            end

                            destPort=get_param(line,'Dstporthandle');
                            dest=get_param(destPort,'Parent');
                            ladderImportSimulink.utils.moveBlocktoPositionRelativetoPort...
                            (dest,outport,'r');

                        end

                    end
                end
            end
        end




    end
end

