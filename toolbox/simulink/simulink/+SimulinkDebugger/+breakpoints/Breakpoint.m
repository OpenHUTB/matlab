classdef Breakpoint




    properties
        type_;
        zbreakpoint_;
    end

    properties(Transient=true)

        src_;
        fullBlockPathToTopModel_;
        id_;
        hits_;
        enable_;
    end

end


