// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   InstalledAddonMetadataUtils.java

package com.mathworks.addons_common.util;

import com.mathworks.addons.javacache.JavaCache;
import com.mathworks.addons_common.AddonCustomMetadata;
import com.mathworks.addons_common.InstalledAddon;
import com.mathworks.addons_common.installation_folder.InstallationFolderView;
import com.mathworks.addons_common.installation_folder.InstallationFolderViewFactory;
import com.mathworks.addons_metadata.AddonMetadataProviderWithFolder;
import com.mathworks.jmi.MLFileUtils;
import com.mathworks.metadata_core.AddonCoreMetadata;
import com.mathworks.metadata_core.AddonCoreMetadataImpl;
import com.mathworks.metadata_core.AddonDependency;
import com.mathworks.metadata_core.AddonDependencyMetadata;
import com.mathworks.metadata_core.AddonDependencyMetadataImpl;
import com.mathworks.metadata_core.DocumentationMetadata;
import com.mathworks.metadata_core.DocumentationMetadataImpl;
import com.mathworks.metadata_core.IncludedApp;
import com.mathworks.metadata_core.IncludedAppsMetadata;
import com.mathworks.metadata_core.IncludedAppsMetadataImpl;
import com.mathworks.metadata_core.PathMetadata;
import com.mathworks.metadata_core.PathMetadataImpl;
import com.mathworks.util.ImplementorsCache;
import com.mathworks.util.ImplementorsCacheFactory;
import com.mathworks.util.Log;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.nio.file.CopyOption;
import java.nio.file.FileVisitResult;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.SimpleFileVisitor;
import java.nio.file.attribute.BasicFileAttributes;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Date;
import java.util.Iterator;
import java.util.concurrent.Callable;
import javax.imageio.ImageIO;

// Referenced classes of package com.mathworks.addons_common.util:
//            InstalledAddonMetadataModifier, AddonMetadataResolver, AddonMetadataResolverFactory

public class InstalledAddonMetadataUtils
{
    private static class AddonCodeFilesVisitor extends SimpleFileVisitor
    {

        public FileVisitResult visitFile(Path path, BasicFileAttributes basicfileattributes)
            throws IOException
        {
            File file = path.toFile();
            if(MLFileUtils.isMatlabCodeFile(file.getName()) || MLFileUtils.isMlappFile(file.getName()))
                matlabCodeFilePaths.add(file.getPath());
            return super.visitFile(path, basicfileattributes);
        }

        ArrayList getMatlabCodeFilePaths()
        {
            return matlabCodeFilePaths;
        }

        public volatile FileVisitResult visitFile(Object obj, BasicFileAttributes basicfileattributes)
            throws IOException
        {
            return visitFile((Path)obj, basicfileattributes);
        }

        private ArrayList matlabCodeFilePaths;

        AddonCodeFilesVisitor()
        {
            matlabCodeFilePaths = new ArrayList();
        }
    }

    private static class LazyHolder
    {

        private static final Collection INSTANCE = ImplementorsCacheFactory.getInstance().getImplementors(com/mathworks/addons_common/util/InstalledAddonMetadataModifier);



        private LazyHolder()
        {
        }
    }


    private static Collection getModifiers()
    {
        return LazyHolder.INSTANCE;
    }

    public static boolean installedAddonToMetadataFolder(File file, InstalledAddon installedaddon)
    {
        AddonMetadataProviderWithFolder addonmetadataproviderwithfolder;
        try
        {
            addonmetadataproviderwithfolder = new AddonMetadataProviderWithFolder(file);
        }
        catch(Exception exception)
        {
            return false;
        }
        AddonCoreMetadataImpl addoncoremetadataimpl = null;
        if(!addonmetadataproviderwithfolder.isAddonCoreMetadataAvailable())
        {
            addoncoremetadataimpl = new AddonCoreMetadataImpl();
            addoncoremetadataimpl.setLabel(installedaddon.getName());
            addoncoremetadataimpl.setVersion(installedaddon.getVersion());
            addoncoremetadataimpl.setAddOnType(installedaddon.getType());
            addoncoremetadataimpl.setIdentifier(installedaddon.getIdentifier());
            addoncoremetadataimpl.setSummary(installedaddon.getSummary());
            addoncoremetadataimpl.setDescription(installedaddon.getDescription());
            addoncoremetadataimpl.setCreatedByName(installedaddon.getAuthor());
            File file1 = new File(addonmetadataproviderwithfolder.getMetadataFolder(), "screenshot.png");
            if(!file1.exists())
            {
                BufferedImage bufferedimage = installedaddon.getImage();
                if(null != bufferedimage)
                {
                    if(!addonmetadataproviderwithfolder.getMetadataFolder().exists() && !addonmetadataproviderwithfolder.getMetadataFolder().mkdir())
                        return false;
                    try
                    {
                        ImageIO.write(bufferedimage, "png", file1);
                        addoncoremetadataimpl.setImageFile(file1);
                    }
                    catch(IOException ioexception)
                    {
                        return false;
                    }
                }
            }
            if(file1.exists())
                addoncoremetadataimpl.setImageFile(file1);
        }
        AddonDependencyMetadataImpl addondependencymetadataimpl = null;
        if(installedaddon.hasCustomMetadataWithAttributeName("addonDependencyMetadata") && !addonmetadataproviderwithfolder.isAddonDependencyMetadataAvailable())
        {
            AddonCustomMetadata addoncustommetadata = installedaddon.getCustomMetadataWithAttributeName("addonDependencyMetadata");
            ArrayList arraylist = (ArrayList)addoncustommetadata.getValue()[0];
            if(!arraylist.isEmpty())
            {
                addondependencymetadataimpl = new AddonDependencyMetadataImpl();
                AddonDependency addondependency;
                for(Iterator iterator = arraylist.iterator(); iterator.hasNext(); addondependencymetadataimpl.addDependency(addondependency))
                    addondependency = (AddonDependency)iterator.next();

            }
        }
        IncludedAppsMetadataImpl includedappsmetadataimpl = null;
        String as[] = installedaddon.getRelatedAddOnIdentifiers();
        String as1[] = installedaddon.getRelatedAddOnNames();
        if(as.length > 0 && as1.length > 0 && as.length == as1.length)
        {
            includedappsmetadataimpl = new IncludedAppsMetadataImpl();
            for(int i = 0; i < as.length; i++)
            {
                IncludedApp includedapp = new IncludedApp(as1[i], as[i]);
                includedappsmetadataimpl.addIncludedApp(includedapp);
            }

        }
        PathMetadataImpl pathmetadataimpl = null;
        if(installedaddon.hasCustomMetadataWithAttributeName("matlabPathEntries") && !addonmetadataproviderwithfolder.isMATLABPathEntriesMetadataAvailable())
        {
            pathmetadataimpl = new PathMetadataImpl();
            AddonCustomMetadata addoncustommetadata1 = installedaddon.getCustomMetadataWithAttributeName("matlabPathEntries");
            String as2[] = (String[])(String[])addoncustommetadata1.getValue();
            String as3[] = as2;
            int j = as3.length;
            for(int k = 0; k < j; k++)
            {
                String s = as3[k];
                pathmetadataimpl.addPath(new File(s));
            }

        }
        PathMetadataImpl pathmetadataimpl1 = null;
        if(installedaddon.hasCustomMetadataWithAttributeName("javaClassPathEntries") && !addonmetadataproviderwithfolder.isJavaClassPathEntriesMetadataAvailable())
        {
            pathmetadataimpl1 = new PathMetadataImpl();
            AddonCustomMetadata addoncustommetadata2 = installedaddon.getCustomMetadataWithAttributeName("javaClassPathEntries");
            String as4[] = (String[])(String[])addoncustommetadata2.getValue();
            String as5[] = as4;
            int l = as5.length;
            for(int i1 = 0; i1 < l; i1++)
            {
                String s1 = as5[i1];
                pathmetadataimpl1.addPath(new File(s1));
            }

        }
        File file2 = new File(file, "DesktopToolset.xml");
        if(file2.exists())
            try
            {
                File file3 = addonmetadataproviderwithfolder.getMetadataFolder();
                File file4 = new File(file3, "mltbx_app_gallery_registration.xml");
                if(!file4.exists())
                    Files.copy(file2.toPath(), file4.toPath(), new CopyOption[0]);
            }
            catch(IOException ioexception1)
            {
                Log.logException(ioexception1);
                return false;
            }
        DocumentationMetadataImpl documentationmetadataimpl = null;
        if((installedaddon.hasCustomMetadataWithAttributeName("infoXMLFileForConversion") || installedaddon.hasCustomMetadataWithAttributeName("gettingStartedGuideFileForConversion")) && !addonmetadataproviderwithfolder.isDocumentationMetadataAvailable())
        {
            documentationmetadataimpl = new DocumentationMetadataImpl();
            if(installedaddon.hasCustomMetadataWithAttributeName("infoXMLFileForConversion"))
            {
                AddonCustomMetadata addoncustommetadata3 = installedaddon.getCustomMetadataWithAttributeName("infoXMLFileForConversion");
                File file5 = new File(((String[])(String[])addoncustommetadata3.getValue())[0]);
                documentationmetadataimpl.setInfoXMLPath(file5);
            }
            if(installedaddon.hasCustomMetadataWithAttributeName("gettingStartedGuideFileForConversion"))
            {
                AddonCustomMetadata addoncustommetadata4 = installedaddon.getCustomMetadataWithAttributeName("gettingStartedGuideFileForConversion");
                File file6 = new File(((String[])(String[])addoncustommetadata4.getValue())[0]);
                documentationmetadataimpl.setGettingStartedGuidePath(file6);
            }
        }
        boolean flag = true;
        if(null != addoncoremetadataimpl)
        {
            flag &= addonmetadataproviderwithfolder.setAddonCoreMetadata(addoncoremetadataimpl);
            addoncoremetadataimpl.dispose();
        }
        if(null != addondependencymetadataimpl)
        {
            flag &= addonmetadataproviderwithfolder.setAddonDependencyMetadata(addondependencymetadataimpl);
            addondependencymetadataimpl.dispose();
        }
        if(null != includedappsmetadataimpl)
        {
            flag &= addonmetadataproviderwithfolder.setIncludedAppsMetadata(includedappsmetadataimpl);
            includedappsmetadataimpl.dispose();
        }
        if(null != pathmetadataimpl && !pathmetadataimpl.getPaths().isEmpty())
        {
            flag &= addonmetadataproviderwithfolder.setMATLABPathEntriesMetadata(pathmetadataimpl);
            pathmetadataimpl.dispose();
        }
        if(null != pathmetadataimpl1 && !pathmetadataimpl1.getPaths().isEmpty())
        {
            flag &= addonmetadataproviderwithfolder.setJavaClassPathEntriesMetadata(pathmetadataimpl1);
            pathmetadataimpl1.dispose();
        }
        if(null != documentationmetadataimpl)
        {
            flag &= addonmetadataproviderwithfolder.setDocumentationMetadata(documentationmetadataimpl);
            documentationmetadataimpl.dispose();
        }
        return flag;
    }

    public static InstalledAddon metadataFolderToInstalledAddon(File file, String s)
    {
        AddonMetadataProviderWithFolder addonmetadataproviderwithfolder;
        try
        {
            addonmetadataproviderwithfolder = new AddonMetadataProviderWithFolder(file);
        }
        catch(Exception exception)
        {
            return null;
        }
        AddonCoreMetadata addoncoremetadata = addonmetadataproviderwithfolder.getAddonCoreMetadata();
        if(null == addoncoremetadata)
            return null;
        AddonMetadataResolver addonmetadataresolver = AddonMetadataResolverFactory.getResolverForAddonType(addoncoremetadata.getAddOnType());
        com.mathworks.addons_common.InstalledAddon.Builder builder = InstalledAddon.getBuilder(addoncoremetadata.getAddOnType(), addoncoremetadata.getIdentifier(), addoncoremetadata.getLabel(), addoncoremetadata.getVersion(), addoncoremetadata.getCreatedByName(), s);
        builder.displayType(addonmetadataresolver.deriveDisplayType(file.toPath()));
        builder.summary(addoncoremetadata.getSummary());
        builder.description(addoncoremetadata.getDescription());
        builder.enableDisableSupported(true);
        Date date = new Date(file.lastModified());
        builder.installedDate(date);
        builder.installedFolder(file.toPath());
        File file1 = addoncoremetadata.getImageFile();
        if(null != file1 && file1.exists())
            try
            {
                BufferedImage bufferedimage = ImageIO.read(file1);
                builder.imageProvider(new Callable(bufferedimage) {

                    public BufferedImage call()
                        throws Exception
                    {
                        return theImage;
                    }

                    public volatile Object call()
                        throws Exception
                    {
                        return call();
                    }

                    final BufferedImage val$theImage;

            
            {
                theImage = bufferedimage;
                super();
            }
                }
);
            }
            catch(IOException ioexception) { }
        AddonCodeFilesVisitor addoncodefilesvisitor = new AddonCodeFilesVisitor();
        InstallationFolderView installationfolderview = InstallationFolderViewFactory.getViewForExistingFolder(file.toPath());
        if(null != installationfolderview)
        {
            Path path = installationfolderview.getCodeFolder();
            try
            {
                Files.walkFileTree(path, addoncodefilesvisitor);
            }
            catch(IOException ioexception1) { }
            ArrayList arraylist = addoncodefilesvisitor.getMatlabCodeFilePaths();
            if(!arraylist.isEmpty())
            {
                String as[] = new String[arraylist.size()];
                as = (String[])arraylist.toArray(as);
                String as1[] = new String[as.length];
                String s1 = path.toString();
                for(int i = 0; i < as.length; i++)
                    as1[i] = as[i].substring(s1.length(), as[i].length());

                builder.hasDetailPage(true);
                builder.fileName(as1);
                builder.absoluteFilePath(as);
            }
        }
        AddonDependencyMetadata addondependencymetadata = addonmetadataproviderwithfolder.getAddonDependencyMetadata();
        if(null != addondependencymetadata)
        {
            ArrayList arraylist1 = new ArrayList(addondependencymetadata.getDependencies());
            builder.customMetadata("addonDependencyMetadata", new AddonCustomMetadata(arraylist1) {

                public Object[] getValue()
                {
                    ArrayList aarraylist[] = new ArrayList[1];
                    aarraylist[0] = depList;
                    return aarraylist;
                }

                final ArrayList val$depList;

            
            {
                depList = arraylist;
                super();
            }
            }
);
        }
        IncludedAppsMetadata includedappsmetadata = addonmetadataproviderwithfolder.getIncludedAppsMetadata();
        if(null != includedappsmetadata)
        {
            java.util.List list = includedappsmetadata.getIncludedApps();
            String as2[] = new String[list.size()];
            String as3[] = new String[list.size()];
            for(int j = 0; j < list.size(); j++)
            {
                IncludedApp includedapp = (IncludedApp)list.get(j);
                as2[j] = includedapp.getIdentifier();
                as3[j] = includedapp.getLabel();
            }

            builder.relatedAddOnIdentifiers(as2);
            builder.relatedAddOnNames(as3);
            includedappsmetadata.dispose();
        }
        PathMetadata pathmetadata = addonmetadataproviderwithfolder.getMATLABPathEntriesMetadata();
        if(null != pathmetadata)
        {
            convertPathMetadata(builder, "matlabPathEntries", pathmetadata);
            pathmetadata.dispose();
        }
        PathMetadata pathmetadata1 = addonmetadataproviderwithfolder.getJavaClassPathEntriesMetadata();
        if(null != pathmetadata1)
        {
            convertPathMetadata(builder, "javaClassPathEntries", pathmetadata1);
            convertJavaCacheMetadata(builder, addoncoremetadata, pathmetadata1);
            pathmetadata1.dispose();
        }
        DocumentationMetadata documentationmetadata = addonmetadataproviderwithfolder.getDocumentationMetadata();
        if(null != documentationmetadata)
        {
            File file2 = documentationmetadata.getInfoXMLPath();
            if(null != file2 && file2.exists())
                builder.customMetadata("infoXMLFileForConversion", new AddonCustomMetadata(file2) {

                    public String[] getValue()
                    {
                        return (new String[] {
                            infoXmlFile.getAbsolutePath()
                        });
                    }

                    public volatile Object[] getValue()
                    {
                        return getValue();
                    }

                    final File val$infoXmlFile;

            
            {
                infoXmlFile = file;
                super();
            }
                }
);
            File file3 = documentationmetadata.getGettingStartedGuidePath();
            if(null != file3 && file3.exists())
                builder.customMetadata("gettingStartedGuideFileForConversion", new AddonCustomMetadata(file3) {

                    public String[] getValue()
                    {
                        return (new String[] {
                            gsGuide.getAbsolutePath()
                        });
                    }

                    public volatile Object[] getValue()
                    {
                        return getValue();
                    }

                    final File val$gsGuide;

            
            {
                gsGuide = file;
                super();
            }
                }
);
        }
        InstalledAddonMetadataModifier installedaddonmetadatamodifier;
        for(Iterator iterator = getModifiers().iterator(); iterator.hasNext(); installedaddonmetadatamodifier.ModifyInstalledAddonBuilderFromMetadata(addoncoremetadata.getAddOnType(), builder, addonmetadataproviderwithfolder))
            installedaddonmetadatamodifier = (InstalledAddonMetadataModifier)iterator.next();

        addoncoremetadata.dispose();
        return builder.createInstalledAddon();
    }

    private static void convertPathMetadata(com.mathworks.addons_common.InstalledAddon.Builder builder, String s, PathMetadata pathmetadata)
    {
        java.util.List list = pathmetadata.getPaths();
        if(!list.isEmpty())
        {
            ArrayList arraylist = new ArrayList(list.size());
            File file;
            for(Iterator iterator = list.iterator(); iterator.hasNext(); arraylist.add(file.getAbsolutePath()))
                file = (File)iterator.next();

            builder.customMetadata(s, new AddonCustomMetadata(arraylist) {

                public String[] getValue()
                {
                    return (String[])pathData.toArray(InstalledAddonMetadataUtils.STRING_ARRAY);
                }

                public volatile Object[] getValue()
                {
                    return getValue();
                }

                final Collection val$pathData;

            
            {
                pathData = collection;
                super();
            }
            }
);
        }
    }

    private static void convertJavaCacheMetadata(com.mathworks.addons_common.InstalledAddon.Builder builder, AddonCoreMetadata addoncoremetadata, PathMetadata pathmetadata)
    {
        String s = addoncoremetadata.getIdentifier();
        String s1 = addoncoremetadata.getVersion();
        ArrayList arraylist = new ArrayList(pathmetadata.getPaths().size());
        for(Iterator iterator = pathmetadata.getPaths().iterator(); iterator.hasNext();)
        {
            File file = (File)iterator.next();
            try
            {
                arraylist.add(JavaCache.copyToJavaCache(s, s1, file.getAbsolutePath()));
            }
            catch(IOException ioexception)
            {
                arraylist.add(file.getAbsolutePath());
            }
        }

        builder.customMetadata("javaClassPathEntriesConverted", new AddonCustomMetadata(arraylist) {

            public String[] getValue()
            {
                return (String[])convertedPaths.toArray(InstalledAddonMetadataUtils.STRING_ARRAY);
            }

            public volatile Object[] getValue()
            {
                return getValue();
            }

            final java.util.List val$convertedPaths;

            
            {
                convertedPaths = list;
                super();
            }
        }
);
    }

    private InstalledAddonMetadataUtils()
    {
    }

    private static final String MATLAB_PATH_ENTRIES = "matlabPathEntries";
    private static final String JAVA_CLASS_PATH_ENTRIES = "javaClassPathEntries";
    private static final String JAVA_CLASS_PATH_ENTRIES_CONVERTED = "javaClassPathEntriesConverted";
    private static final String CONVERSION_INFO_XML_LOCATION = "infoXMLFileForConversion";
    private static final String CONVERSION_GSG_LOCATION = "gettingStartedGuideFileForConversion";
    private static final String ADDON_DEPENDENCIES = "addonDependencyMetadata";
    private static final String TOOLBOX_TOOLSET_CONTENTS_FILE = "DesktopToolset.xml";
    private static final String TOOLBOX_APP_GALLERY_REGISTRATION_FILE = "mltbx_app_gallery_registration.xml";
    public static final String STRING_ARRAY[] = new String[0];

}
