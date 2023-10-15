classdef ( Hidden )cvdatamgr < handle

    properties ( GetAccess = public, Hidden )
        ModuleName2Instances
    end

    methods ( Access = protected )

        function this = cvdatamgr(  )

            this.init(  );
        end
    end

    methods ( Hidden )

        function addOrUpdate( this, cvd )
            arguments
                this( 1, 1 )cv.coder.cvdatamgr
                cvd( 1, 1 )cv.coder.cvdata
            end

            if ~isvalid( cvd ) || ~cvd.valid(  )
                return
            end


            moduleName = cvd.moduleinfo.name;
            if this.ModuleName2Instances.isKey( moduleName )
                moduleInstances = this.ModuleName2Instances( moduleName );
            else
                moduleInstances = containers.Map( 'KeyType', 'char', 'ValueType', 'any' );
            end


            dataId = cvd.uniqueId;
            if moduleInstances.isKey( dataId )
                cvdInfo = moduleInstances( dataId );
            else
                cvdInfo = struct( 'numInstances', 0, 'valueRef', [  ] );
            end
            cvdInfo.numInstances = cvdInfo.numInstances + 1;
            cvdInfo.valueRef = cvd;


            moduleInstances( dataId ) = cvdInfo;
            this.ModuleName2Instances( moduleName ) = moduleInstances;
        end




        function cvd = get( this, moduleName, dataId )
            arguments
                this( 1, 1 )cv.coder.cvdatamgr
                moduleName( 1, : )char
                dataId( 1, : )char
            end

            cvd = [  ];
            if isempty( this.ModuleName2Instances )
                return
            end

            if this.ModuleName2Instances.isKey( moduleName )
                moduleInstances = this.ModuleName2Instances( moduleName );
                if moduleInstances.isKey( dataId )
                    cvdInfo = moduleInstances( dataId );
                    cvd = cvdInfo.valueRef;
                end
            end
        end




        function remove( this, cvd, force )
            arguments
                this( 1, 1 )cv.coder.cvdatamgr
                cvd( 1, 1 )cv.coder.cvdata
                force( 1, 1 )logical = false
            end


            if ~cvd.valid(  ) || isempty( this.ModuleName2Instances )
                return
            end


            moduleName = cvd.moduleinfo.name;
            if this.ModuleName2Instances.isKey( moduleName )
                moduleInstances = this.ModuleName2Instances( moduleName );


                dataId = cvd.uniqueId;
                if moduleInstances.isKey( dataId )
                    cvdInfo = moduleInstances( dataId );
                    cvdInfo.numInstances = cvdInfo.numInstances - 1;


                    if cvdInfo.numInstances < 1 || force
                        moduleInstances.remove( dataId );
                    else
                        moduleInstances( dataId ) = cvdInfo;
                    end
                end


                if isempty( moduleInstances )
                    this.ModuleName2Instances.remove( moduleName );
                else
                    this.ModuleName2Instances( moduleName ) = moduleInstances;
                end
            end
        end





        function removeAll( this, moduleName )
            arguments
                this( 1, 1 )cv.coder.cvdatamgr
                moduleName( 1, : )char = ''
            end

            if isempty( this.ModuleName2Instances )
                return
            end

            if ~isempty( moduleName ) && this.ModuleName2Instances.isKey( moduleName )
                this.ModuleName2Instances.remove( moduleName );
            end
            this.init(  );
        end
    end

    methods ( Access = protected )
        function init( this )
            this.ModuleName2Instances = containers.Map( 'KeyType', 'char', 'ValueType', 'any' );
        end
    end

    methods ( Static, Hidden )



        function obj = instance(  )
            persistent singleton;
            if isempty( singleton )
                singleton = cv.coder.cvdatamgr(  );
            end
            obj = singleton;
        end
    end
end


