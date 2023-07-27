// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   FolderNameUtils.java

package com.mathworks.addons_common.util;

import com.mathworks.mvm.exec.MvmExecutionException;
import com.mathworks.resources_folder.ResourcesFolderUtils;
import com.mathworks.services.Prefs;
import com.mathworks.util.*;
import java.io.File;
import java.io.IOException;
import java.nio.file.*;
import java.nio.file.attribute.FileAttribute;
import java.util.concurrent.*;
import javax.swing.SwingUtilities;

// Referenced classes of package com.mathworks.addons_common.util:
//            UserCreatedFolderAndFileDetector, CheckFileEndingVisitor, AddonsMatlabWorker

public final class FolderNameUtils
{

    private FolderNameUtils()
    {
    }

    public static File getUsersHomeDirectory()
        throws MvmExecutionException, InterruptedException
    {
        Path path = getFirstFolderInUserPath();
        if(!path.toString().isEmpty() && Files.exists(path, new LinkOption[0]) && Files.isWritable(path))
        {
            return path.toFile();
        } else
        {
            Path path1 = Paths.get(executeFEval("system_dependent", ARGS_FOR_SYSTEM_DEPENDENT), new String[0]);
            return path1.toFile();
        }
    }

    public static Path getDefaultAddonInstallLocation()
    {
        Path path = Paths.get(Prefs.getPropertyDirectory(), new String[0]);
        Path path1 = path;
        if(hasParent(path))
        {
            path1 = path1.getParent();
            if(hasParent(path1))
                path1 = path1.getParent();
        }
        return path1.resolve("MATLAB Add-Ons");
    }

    private static boolean hasParent(Path path)
    {
        try
        {
            if(path.getParent() != null)
                return true;
        }
        catch(Exception exception)
        {
            Log.logException(exception);
        }
        return false;
    }

    static Path getFirstFolderInUserPath()
        throws MvmExecutionException, InterruptedException
    {
        if(FactoryUtils.isMatlabThread())
        {
            if(sFirstFolderInUserPath == null)
                throw new UnsupportedOperationException("The first invocation of this method cannot be on the MATLAB thread.");
        } else
        {
            String s = executeFEval("userpath", EMPTY_ARGS);
            String as[] = s.split(File.pathSeparator);
            sFirstFolderInUserPath = Paths.get(as[0], new String[0]);
        }
        return sFirstFolderInUserPath;
    }

    static String executeFEval(String s, Object aobj[])
        throws MvmExecutionException, InterruptedException
    {
        Callable callable = getFevalTask(s, aobj);
        String s1 = null;
        if(SwingUtilities.isEventDispatchThread())
        {
            s1 = runOnNonEdt(callable);
            return s1;
        }
        try
        {
            s1 = (String)callable.call();
        }
        catch(Exception exception)
        {
            Log.logException(exception);
        }
        return s1;
    }

    private static String runOnNonEdt(Callable callable)
    {
        ExecutorService executorservice = ThreadUtils.newSingleDaemonThreadExecutor("Execute MATLAB command on non-EDT.");
        Future future = executorservice.submit(callable);
        String s = null;
        try
        {
            s = (String)future.get();
        }
        catch(InterruptedException interruptedexception)
        {
            Thread.currentThread().interrupt();
        }
        catch(ExecutionException executionexception)
        {
            Log.logException(executionexception);
        }
        return s;
    }

    private static Callable getFevalTask(String s, Object aobj[])
    {
        return new Callable(s, aobj) {

            public String call()
                throws MvmExecutionException, InterruptedException
            {
                AddonsMatlabWorker addonsmatlabworker = new AddonsMatlabWorker(command, args);
                addonsmatlabworker.start();
                return (String)addonsmatlabworker.get();
            }

            public volatile Object call()
                throws Exception
            {
                return call();
            }

            final String val$command;
            final Object val$args[];

            
            {
                command = s;
                args = aobj;
                super();
            }
        }
;
    }

    /**
     * @deprecated Method createAddonInstallationPath is deprecated
     */

    public static Path createAddonInstallationPath(Path path, String s)
        throws IOException, AccessDeniedException
    {
        return createNormalizedDestinationFolder(path, s);
    }

    public static Path createNormalizedDestinationFolder(Path path, String s)
        throws IOException, AccessDeniedException
    {
        String s1 = normalizeForFolderName(s);
        Path path1 = path.resolve(s1);
        String s2 = getAddonFolderName(path, s1, path1);
        Path path2 = path.resolve(s2);
        if(!Files.exists(path2, new LinkOption[0]))
            Files.createDirectories(path2, new FileAttribute[0]);
        return path2;
    }

    private static String getAddonFolderName(Path path, String s, Path path1)
    {
        String s1 = s;
        if(Files.isRegularFile(path1, new LinkOption[0]) || Files.isDirectory(path1, new LinkOption[0]) && doesUserCreatedFileOrFolderExists(path1))
            s1 = getAddonFolderNameWithIncrementedCounter(path, s, 2);
        return s1;
    }

    private static String getAddonFolderNameWithIncrementedCounter(Path path, String s, int i)
    {
        String s1 = s;
        int j = i;
        Path path1 = path.resolve((new StringBuilder()).append(s1).append("(").append(j).append(")").toString());
        boolean flag = path1.toFile().exists();
        if(flag)
        {
            j++;
            return getAddonFolderNameWithIncrementedCounter(path, s1, j);
        } else
        {
            s1 = (new StringBuilder()).append(s1).append("(").append(j).append(")").toString();
            return s1;
        }
    }

    private static String normalizeForFolderName(String s)
    {
        return s.trim().replaceFirst("^(@|\\+|private)*", "").replaceAll("(\\\\|\\||/|<|>|;|\\*|\"|:|\\?)", "_");
    }

    /**
     * @deprecated Method getMetadataFolderName is deprecated
     */

    public static Path getMetadataFolderName()
    {
        return ResourcesFolderUtils.getResourcesFolderName();
    }

    public static boolean doesUserCreatedFileOrFolderExists(Path path)
    {
        UserCreatedFolderAndFileDetector usercreatedfolderandfiledetector = new UserCreatedFolderAndFileDetector(path);
        try
        {
            Files.walkFileTree(path, usercreatedfolderandfiledetector);
        }
        catch(IOException ioexception)
        {
            Log.logException(ioexception);
            return true;
        }
        return usercreatedfolderandfiledetector.doesUserCreatedFileOrFolderExists().booleanValue();
    }

    public static boolean containsOnlyJars(Path path)
    {
        CheckFileEndingVisitor checkfileendingvisitor = new CheckFileEndingVisitor("jar");
        try
        {
            Files.walkFileTree(path, checkfileendingvisitor);
        }
        catch(IOException ioexception)
        {
            Log.logException(ioexception);
            return false;
        }
        return checkfileendingvisitor.onlyContainsFileEnding();
    }

    public static final String MATLAB_ADD_ONS = "MATLAB Add-Ons";
    private static final String USER_PATH = "userpath";
    private static final Object EMPTY_ARGS[] = new Object[0];
    private static final String SYSTEM_DEPENDENT = "system_dependent";
    private static final Object ARGS_FOR_SYSTEM_DEPENDENT[] = {
        "getuserworkfolder", "default"
    };
    private static Path sFirstFolderInUserPath = null;

}
