classdef AdapterDataTester < handle

    properties ( Hidden, SetAccess = private, GetAccess = private )
        adapterInst
        checksum
        dsWks
        wks
        mfModel
        changeReport
    end


    properties ( SetAccess = private, Dependent )
        WorkspaceVariables
    end


    methods

        function this = AdapterDataTester( adapterInstance, source, section )
            arguments
                adapterInstance( 1, 1 )Simulink.data.adapters.BaseMatlabFileAdapter
                source{ mustBeTextScalar }
                section{ mustBeTextScalar }
            end
            [ dir, ~, ~ ] = fileparts( source );
            if isempty( dir )
                source = which( source );
            end
            if ~adapterInstance.supportsReading( source ) || ~adapterInstance.open( source, section )
                error( 'sl_data_adapter:messages:AdapterDataTesterUnableToOpen',  ...
                    string( message( 'sl_data_adapter:messages:AdapterDataTesterUnableToOpen' ) ) )
            end
            this.adapterInst = adapterInstance;
            this.wks = matlab.internal.lang.Workspace;
            this.dsWks =  ...
                Simulink.data.DataSourceWorkspace.createWithInternalWorkspace(  ...
                this.wks );
            this.mfModel = mf.zero.Model;
            this.changeReport = Simulink.data.adapters.ChangeReport( this.mfModel );
            this.checksum = '';

        end

        function diagnostics = readFromSource( this, prevChecksum )
            arguments
                this( 1, 1 )Simulink.data.adapters.AdapterDataTester
                prevChecksum{ mustBeTextScalar } = '';
            end
            if nargin > 1
                chksum = prevChecksum;
            else
                chksum = this.checksum;
            end
            diag.AdapterDiagnostic = Simulink.data.adapters.AdapterDiagnostic.NoDiagnostic;
            diag.DiagnosticMessage = '';
            diagnostics = this.adapterInst.getData( this.dsWks, chksum, diag );
            this.checksum = this.adapterInst.getCurrentChecksum(  );
        end

        function map = get.WorkspaceVariables( this )
            map = containers.Map(  );
            names = this.dsWks.listVariables(  );
            if ( ~isempty( names ) )
                values = this.dsWks.getVariables( names );
                map = containers.Map( names, values );
            end
        end

        function clear( this )
            this.dsWks.clearAllVariables(  );
            this.checksum = '';
            this.changeReport.changes.destroyAllContents;
        end


    end

    methods ( Hidden )
        function diagnostics = writeToSource( this )
            arguments
                this( 1, 1 )Simulink.data.adapters.AdapterDataTester
            end
            diag.AdapterDiagnostic = Simulink.data.adapters.AdapterDiagnostic.NoDiagnostic;
            diag.DiagnosticMessage = '';
            diagnostics = this.adapterInst.writeData( this.dsWks, this.changeReport, diag );

        end

        function setVariable( this, var, val )
            arguments
                this( 1, 1 )Simulink.data.adapters.AdapterDataTester
                var{ mustBeTextScalar, mustBeNonempty }
                val
            end
            var = convertCharsToStrings( var );
            [ isChanged, changeType ] = this.detectChangeType( var, val );
            if isChanged
                this.addTochangeReport( changeType, var );
                this.dsWks.setVariable( var, val )
            end
        end

        function clearVariables( this, var )
            arguments
                this( 1, 1 )Simulink.data.adapters.AdapterDataTester
                var{ mustBeText, mustBeNonempty, mustBeVector };
            end
            changeType = Simulink.data.adapters.ChangeType.Delete;
            var = convertCharsToStrings( var );
            for v = var
                if this.dsWks.hasVariables( v )
                    this.addTochangeReport( changeType, v );
                end
            end
            this.dsWks.clearVariables( var );
        end

        function resetChangeReport( this )
            this.changeReport.changes.destroyAllContents;
        end

        function changeReport = testHook_getChangeReport( this )
            changeReport = this.changeReport;
        end

        function checksum = testHook_getStoredChecksum( this )
            checksum = this.checksum;
        end

    end

    methods ( Access = private )

        function addTochangeReport( this, changeType, id )
            changeTuple = Simulink.data.adapters.ChangeTuple( this.mfModel );
            changeTuple.type = changeType;
            changeTuple.id = id;
            this.changeReport.changes.add( changeTuple );
        end

        function [ ischanged, changeType ] = detectChangeType( this, var, val )
            ischanged = false;
            changeType = [  ];
            if this.dsWks.hasVariables( var )
                if ~isequal( this.dsWks.getVariable( var ), val )
                    changeType = Simulink.data.adapters.ChangeType.Modify;
                    ischanged = true;
                end
            else
                changeType = Simulink.data.adapters.ChangeType.Create;
                ischanged = true;
            end
        end

    end


end
