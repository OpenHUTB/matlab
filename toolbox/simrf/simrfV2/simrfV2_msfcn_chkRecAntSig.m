function simrfV2_msfcn_chkRecAntSig(block)





    setup(block);



    function setup(block)


        block.NumInputPorts=1;
        block.NumOutputPorts=1;
        block.NumDialogPrms=2;
        block.AllowSignalsWithMoreThan2D=1;



        block.SetPreCompInpPortInfoToDynamic;
        block.SetPreCompOutPortInfoToDynamic;

        block.InputPort(1).DirectFeedthrough=true;
        block.InputPort(1).DatatypeID=0;
        block.InputPort(1).Complexity='Inherited';
        block.OutputPort(1).Complexity='Inherited';


        block.SampleTimes=[-1,0];


        block.SimStateCompliance='DefaultSimState';


        block.RegBlockMethod('SetInputPortDimensions',@SetInpPortDims);
        block.RegBlockMethod('Outputs',@Output);



        function SetInpPortDims(block,port,di)

            if block.DialogPrm(2).Data==1
                if numel(di)==1





                    if block.DialogPrm(1).Data~=1&&di~=block.DialogPrm(1).Data
                        DAStudio.error('simrf:simrfV2errors:AntennaInSizeMismatchFreqs');
                    end
                elseif numel(di)==2





                    if di(2)~=block.DialogPrm(1).Data
                        DAStudio.error('simrf:simrfV2errors:AntennaInSizeMismatchFreqs');
                    end
                elseif numel(di)==3


                    coder.internal.errorIf(true,'simrf:simrfV2errors:AntennaInSizeMismatchIso');
                end
            else
                if numel(di)~=3||di(3)~=2
                    DAStudio.error('simrf:simrfV2errors:AntennaInSizeMismatch2Pol');
                end
                if block.DialogPrm(1).Data==1



                    if di(2)~=1
                        DAStudio.error('simrf:simrfV2errors:AntennaInSizeMismatchFreqs');
                    end
                else




                    if di(1)~=block.DialogPrm(1).Data&&di(2)~=block.DialogPrm(1).Data
                        DAStudio.error('simrf:simrfV2errors:AntennaInSizeMismatchFreqs');
                    end
                end
            end
            block.InputPort(port).Dimensions=di;
            block.OutputPort(port).Dimensions=di;



            function Output(block)

                block.OutputPort(1).Data=block.InputPort(1).Data;


