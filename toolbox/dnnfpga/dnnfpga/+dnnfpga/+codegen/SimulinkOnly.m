


classdef SimulinkOnly
    methods(Static)


        function num=getFixedVectorCount(t,fixedSizeMax)
            coder.allowpcode('plain');
            if nargin<2||fixedSizeMax==0
                fixedSizeMax=dnnfpga.codegen.Packed.fixedSizeMax();
            end
            sz=dnnfpga.codegen.SimulinkOnly.getBitSizeFromType(t);
            num=dnnfpga.codegen.Packed.getFixedVectorCount(sz,fixedSizeMax);
        end


        function num=getFixedVectorSize(t,fixedSizeMax)
            coder.allowpcode('plain');
            if nargin<2||fixedSizeMax==0
                fixedSizeMax=dnnfpga.codegen.Packed.fixedSizeMax();
            end
            sz=dnnfpga.codegen.SimulinkOnly.getBitSizeFromType(t);
            num=dnnfpga.codegen.Packed.getFixedVectorSize(sz,fixedSizeMax);
        end




        function sz=getBitSizeFromType(t)
            coder.allowpcode('plain');
            sz=uint32(0);
            try

                elements=t.Elements();
                for i=1:numel(elements)
                    elem=elements(i);
                    sz=sz+dnnfpga.codegen.SimulinkOnly.getBitSizeFromType(elem);
                end
            catch
                try

                    sz=dnnfpga.codegen.SimulinkOnly.getBitSizeFromType(t.DataType);
                    ignore=repmat(false,t.Dimensions);
                    sz=sz*uint32(numel(ignore));
                catch
                    try

                        value=cast(0,t);
                        sz=dnnfpga.codegen.Packed.getBitSize(value);
                    catch
                        try
                            if contains(t,'Enum:')
                                name=strrep(t,'Enum:','');
                                classes=Simulink.findIntEnumType();
                                for i=1:numel(classes)
                                    cls=classes(i);
                                    if strcmp(name,cls.Name)
                                        ev=cls.EnumerationMemberList(1);
                                        value=eval(strcat(name,'.',ev.Name));
                                        sz=dnnfpga.codegen.Packed.getBitSize(value);
                                        break;
                                    end
                                end
                            elseif contains(t,'boolean')
                                sz=uint32(1);
                            else
                                value=eval(t);
                                sz=dnnfpga.codegen.Packed.getBitSize(value);
                            end
                        catch
                            try
                                value=Simulink.Bus.createMATLABStruct(t);
                                sz=dnnfpga.codegen.Packed.getBitSize(value);
                            catch
                                error("Unexpected type.");
                            end
                        end
                    end
                end
            end
        end
    end
end
