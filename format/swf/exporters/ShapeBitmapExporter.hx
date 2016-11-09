package format.swf.exporters;

import haxe.ds.Option;

import format.swf.exporters.core.ShapeCommand;
import openfl.geom.Matrix;


/*
* When you export a swf from flash, it saves all bitmap draws as Shapes, with a graphics that has one or more BeginBitmapFills.
* swf does NOT add bitmap symbols to the stage, as you could expect.
* This is inneficient in openfl, since it uses Cairo (software) to draw all graphics commands, meaning that all
* swf bitmaps will be rendered using software. This is obviously very slow.
*
* ShapeBitmapExporter fixes this, by parsing graphics commands into distinct bitmap draws. 
* These are then replaced with Bitmap instances in swf lite and rendered using hardware.
*
* ShapeBitmapExporter ONLY works if the graphics calls specifically draw bitmaps in the format specified by the SWF.
* Any other format will not return any BitmapFills and will be rendered by software in Cairo.
*/

typedef BitmapFill = {
    id:Int, 
    transform:Matrix
}

class ShapeBitmapExporter
{
    
    public static function process(exporter:ShapeCommandExporter):Array<BitmapFill> 
    {
        var bitmaps = [];
        var commands = exporter.commands.copy();
        var eligable = commands != null && commands.length > 0 && commands.length % 9 == 0;
        
        if(!eligable) {
            
            return null;    
            
        } 
        
        while(commands.length > 0){
            
            switch(processNextBitmap(commands.splice(0, 9))){
                
                case Some(bitmap) : bitmaps.push(bitmap);
                case None : return null;
                
            }
            
        }
        
        return bitmaps;
    }
    
    //process a single bitmap from a series of graphics commands
    private static function processNextBitmap(commands:Array<ShapeCommand>):Option<BitmapFill> 
    {
        var index = 0;
        var bitmapId:Int = 0;
        var positionX = 0.0;
        var positionY = 0.0;
        var transform:Matrix = null;
        
        //ensure the commands are in the order specified by the swf format, and parse out the bitmap details
        for(command in commands) {
            
            switch(command) {
                
                case LineStyle(null, null, null, null, null, null, null, null) if(index == 0) : null;
                case EndFill if (index == 1) : null;
                case BeginBitmapFill(bid, matrix, repeat, smooth) if(index == 2) : 
                    bitmapId = bid;
                    transform = matrix;
                case MoveTo(x, y) if(index == 3) : 
                    positionX = x;
                    positionY = y;
                case LineTo(x, y) if(index == 4) : null;
                case LineTo(x, y) if(index == 5) : null;
                case LineTo(x, y) if(index == 6) : null;
                case LineTo(x, y) if(index == 7) : null;
                case EndFill if (index == 8) : null;
                default : return None; //does not match the format
                
            }
            
            index++;
            
        }
        
        //default transform if none was supplied
        if(transform == null) {
            
            transform = new Matrix();
            transform.identity();
            
        }
        
        return Some({id:bitmapId, transform:transform});	
    }
}