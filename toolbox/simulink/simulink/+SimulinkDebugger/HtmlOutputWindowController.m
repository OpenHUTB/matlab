

classdef HtmlOutputWindowController<SimulinkDebugger.OutputWindowController



    properties
        webDDG_=[]
        displayedText_='welcome to the Simulink debugger'
    end

    methods
        function this=HtmlOutputWindowController(modelHandle)
            this.webDDG_=DAStudio.WebDDG;
            this.webDDG_.Title='sldebug output';
            this.webDDG_.Html=this.displayedText_;


            editor=GLUE2.Util.findAllEditors(get_param(modelHandle,'Name'));
            studio=editor.getStudio;

            comp=GLUE2.DDGComponent(studio,'sldebugger',this.webDDG_);
            studio.registerComponent(comp);
            studio.moveComponentToDock(comp,'Simulink Debugger Output Window','Right','stacked');
        end

        function printToWindow(this,str)
            this.displayedText_=['<p>',str,'</p>'];
            this.webDDG_.Html=this.displayedText_;
        end

        function appendToWindow(this,str)
            str=['<p>',str,'</p>'];
            this.displayedText_=[this.displayedText_,str];
            this.webDDG_.Html=this.displayedText_;
        end
    end
end


