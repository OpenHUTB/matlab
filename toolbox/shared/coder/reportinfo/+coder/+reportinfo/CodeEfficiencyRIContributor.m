
classdef ( Sealed )CodeEfficiencyRIContributor < coder.reportinfo.RIContributor

    properties ( SetAccess = protected )
        Data
    end

    methods
        function obj = CodeEfficiencyRIContributor( results )
            arguments
                results( 1, 1 )codergui.internal.insight.CodeEfficiencyResults
            end

            obj.Data = obj.processData( results );
        end
    end

    methods ( Static, Access = private )
        function converted = processData( results )
            arguments
                results( 1, 1 )codergui.internal.insight.CodeEfficiencyResults
            end

            template = struct( 'MessageID', '', 'MessageType', 'Info', 'Text', '', 'ScriptID', '',  ...
                'TextStart', '', 'TextLength', '', 'Category', '', 'SubCategory', '' );
            catInfos = results.ActiveCategories;
            converted = cell( 1, numel( catInfos ) );

            for i = 1:numel( catInfos )
                catInfo = catInfos( i );
                records = results.getIssues( catInfo );
                msgs = repmat( template, numel( records ), 1 );

                for j = 1:numel( records )
                    msgs( j ).MessageID = records( j ).MsgID;
                    msgs( j ).Text = message( records( j ).MsgID ).getString(  );
                    msgs( j ).ScriptID = records( j ).ScriptID;
                    msgs( j ).TextStart = records( j ).TextStart;
                    msgs( j ).TextLength = records( j ).TextLength;
                    msgs( j ).Category = catInfo.Tag;
                end
                converted{ i } = msgs;
            end

            converted = vertcat( converted{ : } );
        end
    end
end

