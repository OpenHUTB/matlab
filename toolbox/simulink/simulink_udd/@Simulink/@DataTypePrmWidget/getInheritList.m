function result=getInheritList(option)




    switch option
    case 'Auto'
        result=getInheritAuto;
    case 'BP_In'
        result=getInherit_BP_In;
    case 'BP_In1'
        result=getInherit_BP_In1;
    case 'IR'
        result=getInherit_IR;
    case 'IR_BP'
        result=getInherit_IR_BP;
    case 'BP_TD'
        result=getInherit_BP_TD;
    case 'BP_TD_In1'
        result=getInherit_BP_TD_In1;
    case 'BP_TD_In2'
        result=getInherit_BP_TD_In2;
    case 'In_IR_TD'
        result=getInherit_In_IR_TD;
    case 'CorrIn_IR'
        result=getInherit_CorrIn_IR;
    case 'BP_TD2'
        result=getInherit_BP_TD2;
    case 'IR_Out_TDT'
        result=getInherit_IR_Out_TDT;
    case 'Out_TD'
        result=getInherit_Out_TD;
    case 'In_IR'
        result=getInherit_In_IR;
    case 'IR_In'
        result=getInherit_IR_In;
    case 'In'
        result=getInherit_In;
    case 'InWL'
        result=getInherit_InWL;
    case 'IR_In_Prod'
        result=getInherit_IR_In_Prod;
    case 'In_Prod'
        result=getInherit_In_Prod;
    case 'In_Accum'
        result=getInherit_In_Accum;
    case 'In_TD'
        result=getInherit_In_TD;
    case 'In_Sqrt'
        result=getInherit_IR_In_Sqrt;
    case 'In_RSqrt'
        result=getInherit_IR_In_RSqrt;
    otherwise
        assert(false,'Unsupported option');
    end






    function result=getInheritAuto()
        result={'Inherit: auto'};

        function result=getInherit_BP_In()
            result={
'Inherit: Inherit via back propagation'
'Inherit: Same as input'
            };

            function result=getInherit_BP_In1()
                result={
'Inherit: Inherit via back propagation'
'Inherit: Same as first input'
                };

                function result=getInherit_IR()
                    result={'Inherit: Inherit via internal rule'};

                    function result=getInherit_IR_BP()
                        result={
'Inherit: Inherit via internal rule'
'Inherit: Inherit via back propagation'
                        };

                        function result=getInherit_BP_TD()
                            result={
'Inherit: Inherit via back propagation'
'Inherit: Inherit from table data'
                            };

                            function result=getInherit_BP_TD_In1()
                                result={
'Inherit: Inherit via back propagation'
'Inherit: Inherit from table data'
'Inherit: Same as first input'
                                };

                                function result=getInherit_BP_TD_In2()
                                    result={
'Inherit: Inherit via back propagation'
'Inherit: Inherit from ''Table data'''
'Inherit: Same as first input'
                                    };

                                    function result=getInherit_In_IR_TD()
                                        result={
'Inherit: Same as input'
'Inherit: Inherit from ''Breakpoint data'''
                                        };

                                        function result=getInherit_CorrIn_IR()
                                            result={
'Inherit: Same as corresponding input'
'Inherit: Inherit from ''Breakpoint data'''
                                            };

                                            function result=getInherit_BP_TD2()
                                                result={
'Inherit: Inherit via back propagation'
'Inherit: Inherit from ''Table data'''
                                                };

                                                function result=getInherit_IR_Out_TDT()
                                                    result={
'Inherit: Inherit via internal rule'
'Inherit: Same as output'
                                                    };

                                                    function result=getInherit_Out_TD()
                                                        result={
'Inherit: Inherit from ''Table data'''
'Inherit: Same as output'
                                                        };

                                                        function result=getInherit_In_IR()
                                                            result={
'Inherit: Same as input'
'Inherit: Inherit via internal rule'
                                                            };

                                                            function result=getInherit_IR_In()
                                                                result={
'Inherit: Inherit via internal rule'
'Inherit: Same as input'
                                                                };

                                                                function result=getInherit_In()
                                                                    result={
'Inherit: Same as input'
                                                                    };

                                                                    function result=getInherit_InWL()
                                                                        result={
'Inherit: Same word length as input'
                                                                        };

                                                                        function result=getInherit_IR_In_Prod()
                                                                            result={
'Inherit: Inherit via internal rule'
'Inherit: Same as input'
'Inherit: Same as product output'
                                                                            };

                                                                            function result=getInherit_In_Prod()
                                                                                result={
'Inherit: Same as input'
'Inherit: Same as product output'
                                                                                };

                                                                                function result=getInherit_In_Accum()
                                                                                    result={
'Inherit: Same as input'
'Inherit: Same as accumulator'
                                                                                    };

                                                                                    function result=getInherit_In_TD()
                                                                                        result={
'Inherit: Inherit from ''Table data'''
                                                                                        };

                                                                                        function result=getInherit_IR_In_Sqrt()
                                                                                            result={
'Inherit: Inherit via internal rule'
'Inherit: Inherit via back propagation'
'Inherit: Same as first input'
                                                                                            };

                                                                                            function result=getInherit_IR_In_RSqrt()
                                                                                                result={
'Inherit: Inherit via internal rule'
'Inherit: Inherit from input'
'Inherit: Inherit from output'
                                                                                                };


