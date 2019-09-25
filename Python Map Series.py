import os
import arcpy
from arcpy import mapping
from reportlab.pdfgen import canvas
from reportlab.lib.pagesizes import letter
from reportlab.lib.pagesizes import landscape
from reportlab.lib.pagesizes import legal
from PyPDF2 import PdfFileReader, PdfFileWriter, PdfFileMerger
##map properties
arcpy.env.workspace = r"\Highlands.gdb"
gdb = r"\Highlands.gdb"
arcpy.env.overwriteOutput = True

Summary = os.path.join(gdb,'pl2')
Preserved_Lands = os.path.join(gdb,'Preserved_Lands')
NJ_Muns = os.path.join(gdb,'NJ_Municipalities')
Preserve_Lands_Symb = r"\Preserved_Lands.lyr"
Mun_Symb = r"\NJ_Municipalities.lyr"

SummaryFields = ['mun','county','county_acres','farmland_acres','federal_acres','municipal_acres',
'nonprofit_acres', 'private_acres','state_acres','tdr_acres','wsma_acres','SHAPE@','mun_code']

def text(tname):
    if tname == elm.text: elm.text = v

def add_to_map(flayer, symbology):
    df = arcpy.mapping.ListDataFrames(mxd)[0]
    layer = arcpy.mapping.Layer(flayer)
    arcpy.ApplySymbologyFromLayer_management(layer, symbology)
    arcpy.mapping.AddLayer(df, layer)

def zoom_export(layer,mxd,pdfn):
    AllLayers = arcpy.mapping.ListLayers(mxd)
    for x in AllLayers:
        if x.name == layer:
            print x.name
            zoom = x
            arcpy.SelectLayerByAttribute_management(zoom)
            df.extent = zoom.getSelectedExtent()
            df.scale = df.scale * 1.3
            arcpy.RefreshActiveView()
            arcpy.mapping.ExportToPDF(mxd, pdfn)
            print 'hmm'
            arcpy.SelectLayerByAttribute_management(zoom, "CLEAR_SELECTION")
            return True

def pdf_merge(path,output):
    merger = PdfFileMerger()
    path = path
    for filename in os.listdir(path):
        if filename[-3:] == 'pdf':
            print filename
            merger.append(PdfFileReader(file(filename, 'rb')))
    merger.write(output)
    return output


with arcpy.da.SearchCursor(Summary,SummaryFields) as Preserved_Summary:
    for a in Preserved_Summary:
        table = {}
        mxd = arcpy.mapping.MapDocument(r"C:\Users\Ralph\Documents\Highlands\Highlands4.mxd")
        df = arcpy.mapping.ListDataFrames(mxd)[0]
        table['Muni'],table['Counti'],table['co'],table['far'] = a[0],a[1],a[2],a[3]
        table['fed'],table['mun'],table['np'] = a[4],a[5],a[6]
        table['prv'],table['st'],table['tdr'],table['ws'] = a[7],a[8],a[9],a[10]
        table['geom'],table['mun_code'] = a[11],a[12]
        MUN_CODEQ = "MUN_CODE = '{}'".format(table['mun_code'])
        print MUN_CODEQ
        munMAP = arcpy.MakeFeatureLayer_management(NJ_Muns,"Mun_Select",MUN_CODEQ)
        print int(arcpy.GetCount_management(munMAP).getOutput(0))
        print table

        for k,v in sorted(table.items()):
            for elm in arcpy.mapping.ListLayoutElements(mxd, "TEXT_ELEMENT","*"):
                if elm.text == "County": elm.text = table['Counti']+" "+"County"
                if elm.text == "Municipality": elm.text = table['Muni']
                text(k)
        arcpy.Clip_analysis(Preserved_Lands,munMAP,'preserved')
        add_to_map('preserved',Preserve_Lands_Symb)
        add_to_map('Mun_Select',Mun_Symb)
        pdfn = table['Counti']+" "+table['Muni']+'.pdf'
        zoom_export('Mun_Select',mxd,pdfn)

pdf_merge(r"\Highlands","Highlands_Preserved_Lands_Map_Series.pdf")
