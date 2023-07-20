function simrfV2_msfcn_mean(block)



    setup(block);



    function setup(block)

        block.NumDialogPrms=0;


        block.NumInputPorts=1;
        block.NumOutputPorts=1;



        block.SetPreCompInpPortInfoToDynamic;
        block.SetPreCompOutPortInfoToDynamic;
        block.InputPort(1).DirectFeedthrough=true;


        block.SampleTimes=[-1,0];


        block.SimStateCompliance='DefaultSimState';


        block.RegBlockMethod('PostPropagationSetup',@DoPostPropSetup);
        block.RegBlockMethod('InitializeConditions',@InitConditions);
        block.RegBlockMethod('Outputs',@Output);
        block.RegBlockMethod('Update',@Update);



        function DoPostPropSetup(block)


            block.NumDworks=2;
            block.Dwork(1).Name='x0';
            block.Dwork(1).Dimensions=block.InputPort(1).Dimensions;
            block.Dwork(1).DatatypeID=0;
            block.Dwork(1).Complexity=block.InputPort(1).Complexity;
            block.Dwork(1).UsedAsDiscState=true;

            block.Dwork(2).Name='counter';
            block.Dwork(2).Dimensions=1;
            block.Dwork(2).DatatypeID=0;
            block.Dwork(2).Complexity='real';
            block.Dwork(2).UsedAsDiscState=true;



            function InitConditions(block)


                if strcmpi(block.InputPort(1).Complexity,'complex')
                    block.Dwork(1).Data=zeros(block.InputPort(1).Dimensions,1)+...
                    1j*realmin;
                else
                    block.Dwork(1).Data=zeros(block.InputPort(1).Dimensions,1);
                end
                block.Dwork(2).Data=1;



                function Output(block)

                    block.OutputPort(1).Data=(block.Dwork(1).Data+...
                    block.InputPort(1).Data)/block.Dwork(2).Data;



                    function Update(block)

                        block.Dwork(1).Data=block.Dwork(1).Data+block.InputPort(1).Data;
                        block.Dwork(2).Data=block.Dwork(2).Data+1;



