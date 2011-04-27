﻿/*** HexMap by Grant Skinner. Apr 4, 2009* Visit www.gskinner.com/blog for documentation, updates and more free code.*** Copyright (c) 2011 Grant Skinner* * Permission is hereby granted, free of charge, to any person* obtaining a copy of this software and associated documentation* files (the "Software"), to deal in the Software without* restriction, including without limitation the rights to use,* copy, modify, merge, publish, distribute, sublicense, and/or sell* copies of the Software, and to permit persons to whom the* Software is furnished to do so, subject to the following* conditions:* * The above copyright notice and this permission notice shall be* included in all copies or substantial portions of the Software.* * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES* OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND* NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT* HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR* OTHER DEALINGS IN THE SOFTWARE.**/package  {		import flash.display.Sprite;	import flash.display.BitmapData;	import flash.display.Bitmap;	import flash.display.DisplayObject;	import flash.display.Graphics;	import flash.display.MovieClip;	import flash.geom.Point;	import flash.geom.Matrix;		public class HexMap extends Sprite {			// Constants:			// Public Properties:			// Protected Properties:		protected var _cols:uint;		protected var _rows:uint;		protected var _size:Number;		protected var _triW:Number;		protected var _triH:Number;		protected var _colW:Number;		protected var _rowH:Number;		protected var _tiles:Vector.<HexTile>;		protected var _useBitmapCaching:Boolean=false;		protected var cacheBmpd:BitmapData;		protected var cacheBmp:Bitmap;		protected var canvas:Sprite;		protected var bmpPad:uint=5;		protected var sinVal:Number=Math.sin(Math.PI/6);		protected var cosVal:Number=Math.cos(Math.PI/6);					// Initialization:		public function HexMap(tiles:Vector.<HexTile>,cols:uint=8,rows:uint=8,size:Number=16) {			_size = size;			_cols = cols;			_rows = rows;			_tiles = tiles;									if (tiles.length != cols*rows) {				throw(new Error("HexMap: tiles array should contain "+(cols*rows)+" entries, but contains "+tiles.length));			}						canvas = new Sprite();			useBitmapCaching = false;			calculateMetrics();					}			// Public getter / setters:		public function set size(value:Number):void {			_size = value;			calculateMetrics();		}		public function get size():Number {			return _size;		}				public function set columnWidth(value:Number):void {			size = value/(1+sinVal);		}		public function get columnWidth():Number {			return size * (1+sinVal);		}				public function set useBitmapCaching(value:Boolean):void {			_useBitmapCaching = value;			if (_useBitmapCaching) {				removeChild(canvas);				cacheBmpd = new BitmapData(_cols*_colW+_triW+bmpPad*2,_rows*_rowH+_triH+bmpPad*2,true,0);				cacheBmpd.draw(canvas);				cacheBmp = new Bitmap(cacheBmpd);				cacheBmp.x = cacheBmp.y = -bmpPad;				addChild(cacheBmp);			} else {				if (cacheBmpd) {					removeChild(cacheBmp);					cacheBmpd.dispose();				}				cacheBmpd = null;				cacheBmp = null;				addChild(canvas);			}		}			// Public Methods:		public function getHexPosition(x:Number, y:Number):Point {			var hx:Number = x/_colW>>0;			var hy:Number = (y-(hx%2?_triH:0))/_rowH>>0;			if (x%_colW < _triW) {				var midY:Number = hy*_rowH+(hx%2?_rowH:_triH);				if ( Math.abs(midY-y)*sinVal > x%_colW) {					hx--;					hy += (midY-y < 0?1:0)-(hx%2?1:0);				}			}			return new Point(hx,hy);		}				public function getScreenPosition(hx:Number, hy:Number):Point {			return new Point(hx*_colW+_triW+_size/2, hy*_rowH+_triH+(hx%2?_triH:0));		}				public function renderTileAt(hx:uint,hy:uint):void {			var index:uint = hx*_rows+hy;			renderTile(hx,hy,index,_useBitmapCaching);		}				public function renderTiles():void {			var l:uint = _tiles.length;			while (canvas.numChildren) { canvas.removeChildAt(0); }			for (var i:uint=0; i<l; i++) {				var hx:uint = i/_rows>>0;				var hy:uint = i%_rows;				renderTile(hx,hy,i,false);			}			if (_useBitmapCaching) {				cacheBmpd.fillRect(cacheBmpd.rect,0);				cacheBmpd.draw(canvas,new Matrix(1,0,0,1,bmpPad,bmpPad));			}		}				public function getTileAt(hx:uint,hy:uint):HexTile {			return _tiles[hx*_rows+hy];		}			// Protected Methods:		protected function calculateMetrics():void {			_triW = _size*sinVal;			_triH = _size*cosVal;			_colW = _size+_triW;			_rowH = _triH*2;		}				protected function getTileArt(tile:HexTile):DisplayObject {			// GDS: for now:			var art:DisplayObject = new HexArt();			(art as MovieClip).gotoAndStop(tile.art);			return art;		}				protected function drawEdges(canvas:Sprite,xOffset:Number=0,yOffset:Number=0):void {			var x:Number = xOffset;			var g:Graphics = canvas.graphics;			for (var col:uint=0; col<_cols; col++) {				var y:Number = yOffset + (col%2) ? _triH : 0;				for (var row:uint=0; row<_rows; row++) {					if (row == 0 || col == 0) {						g.moveTo(x, y+_triH);						g.lineTo(x+_triW, y);						g.lineTo(x+_colW, y);					} else {						g.moveTo(x+_colW, y);					}					g.lineTo(x+_colW+_triW, y+_triH);					g.lineTo(x+_colW, y+_rowH);					g.lineTo(x+_triW, y+_rowH);					if (col == 0 || row == _rows-1) {						g.lineTo(x, y+_triH);					}										y += _rowH;				}				x += _colW;			}		}				protected function renderTile(hx:uint,hy:uint,index:uint,draw:Boolean):void {			var tile:HexTile = _tiles[index];			if (tile == null) { return; }			var art:DisplayObject = getTileArt(tile);			var pos:Point = getScreenPosition(hx,hy);			if (draw) {				art.x = pos.x+bmpPad;				art.y = pos.y+bmpPad;				cacheBmpd.draw(art,art.transform.matrix);			} else {				art.x = pos.x;				art.y = pos.y;				if (canvas.numChildren > index) { canvas.removeChildAt(index); }				canvas.addChildAt(art,index);			}		}	}	}