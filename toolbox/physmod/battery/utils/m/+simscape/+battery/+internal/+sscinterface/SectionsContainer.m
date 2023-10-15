classdef ( Sealed, Hidden )SectionsContainer




    properties ( Access = private )
        Sections = simscape.battery.internal.sscinterface.Section.empty;
        IfStatement = simscape.battery.internal.sscinterface.IfStatement.empty;
        ForLoop = simscape.battery.internal.sscinterface.StringItem.empty;
    end

    methods
        function obj = addSection( obj, sectionObj )

            arguments
                obj
                sectionObj{ mustBeNonempty, mustBeScalarOrEmpty, mustBeA( sectionObj,  ...
                    "simscape.battery.internal.sscinterface.Section" ) }
            end



            if isempty( obj.Sections )
                obj.Sections = sectionObj;
            else
                sameSectionIndex = sectionObj == obj.Sections;
                if ( any( sameSectionIndex ) )
                    sectionsToMerge = [ obj.Sections( sameSectionIndex ), sectionObj ];
                    obj.Sections( sameSectionIndex ) = sectionsToMerge.merge(  );
                else
                    obj.Sections( end  + 1 ) = sectionObj;
                end
            end
        end

        function obj = addIfStatement( obj, ifStatement )

            arguments
                obj
                ifStatement{ mustBeA( ifStatement, "simscape.battery.internal.sscinterface.IfStatement" ) }
            end
            obj.IfStatement( end  + 1 ) = ifStatement;
        end

        function obj = addForLoop( obj, forLoop )

            arguments
                obj
                forLoop{ mustBeA( forLoop, "simscape.battery.internal.sscinterface.ForLoop" ) }
            end
            obj.ForLoop( end  + 1 ) = forLoop;
        end

        function sections = getContent( obj )

            sortedSections = obj.Sections.sort(  );
            sections = [ sortedSections, obj.IfStatement, obj.ForLoop ];
        end
    end
end


