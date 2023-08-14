classdef ReservedBusTypes<handle






    properties(Constant)
        MapOfReservedBusTypes={...
        'pixelcontrol','privpixelcontrolbus';...
        'samplecontrol','samplecontrolbus';...
        };
    end
    methods(Access=private)
        function obj=ReservedBusTypes
        end
    end
    methods(Static)
        function singleObj=getInstance
            persistent localObj
            if isempty(localObj)||~isvalid(localObj)
                localObj=SimulinkFixedPoint.AutoscalerUtils.ReservedBusTypes;
            end
            singleObj=localObj;
        end
    end
    methods
        function mapOfReservedBusTypes=getMapOfReservedBusTypes(this)

            mapOfReservedBusTypes=this.MapOfReservedBusTypes;
        end
        function listOfReservedBusTypes=getReservedNames(this)

            listOfReservedBusTypes=this.MapOfReservedBusTypes(:,1);
        end
        function[busObject,nameFound]=getBusObject(this,reservedBusName)


            busObject=[];
            reservedBusTypeIndex=find(strcmp(reservedBusName,this.MapOfReservedBusTypes(:,1)));
            nameFound=false;
            if any(reservedBusTypeIndex)



                try



                    nameFound=true;
                    busObject=eval(this.MapOfReservedBusTypes{reservedBusTypeIndex,2});
                    success=true;
                catch
                    success=false;
                end

                if~success



                    try
                        eval(this.MapOfReservedBusTypes{reservedBusTypeIndex,2});
                        busObject=eval(this.MapOfReservedBusTypes{reservedBusTypeIndex,1});
                        clear(this.MapOfReservedBusTypes{reservedBusTypeIndex,1});
                    catch
                    end
                end
            end
        end
    end
end



