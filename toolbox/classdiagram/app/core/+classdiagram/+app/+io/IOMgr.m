classdef IOMgr


    properties
        App(1,1);
    end

    methods
        function obj=IOMgr(app)
            obj.App=app;
        end

        function loadFrom(obj,filename)
            model=mf.zero.Model;
            reader=classdiagram.internal.io.ReadWriter(model);
            model=reader.load(filename);
            factory=classdiagram.app.io.FileClassDiagramFactory(model,obj.App);
            obj.App.loadFromFactory(factory);
        end

        function saveTo(obj,filename)
            builder=classdiagram.app.io.ClassDiagramIOModelBuilder(obj.App);
            m=builder.build();
            writer=classdiagram.internal.io.ReadWriter(m);
            writer.save(filename);
        end
    end
end

