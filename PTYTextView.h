// -*- mode:objc -*-
/*
 **  PTYTextView.h
 **
 **  Copyright (c) 2002, 2003, 2007
 **
 **  Author: Fabian, Ujwal S. Setlur
 **	     Initial code by Kiichi Kusama
 **          Ported to MobileTerminal (from iTerm) by Allen Porter
 **
 **  This program is free software; you can redistribute it and/or modify
 **  it under the terms of the GNU General Public License as published by
 **  the Free Software Foundation; either version 2 of the License, or
 **  (at your option) any later version.
 **
 **  This program is distributed in the hope that it will be useful,
 **  but WITHOUT ANY WARRANTY; without even the implied warranty of
 **  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 **  GNU General Public License for more details.
 **
 **  You should have received a copy of the GNU General Public License
 **  along with this program; if not, write to the Free Software
 **  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UITextView.h>

#include <sys/time.h>

#define MARGIN  4
#define VMARGIN 4 

// Hack for UIKit non-breaking spaces
#define NO_BREAK_SPACE 0x00A0

typedef enum { CURSOR_UNDERLINE, CURSOR_VERTICAL, CURSOR_BOX } ITermCursorType;

@class VT100Screen;

typedef struct 
{
  int code;
  unsigned int color;
  unsigned int bgColor;
  UIImage *image;
  int count;
} CharCache;
	
enum { SELECT_CHAR, SELECT_WORD, SELECT_LINE };

@interface PTYTextView : UITextView
{
  // anti-alias flag
  BOOL antiAlias;

  // option to not render in bold
  BOOL disableBold;

  BOOL CURSOR;
  BOOL forceUpdate;

  // geometry
  float lineHeight;
  float lineWidth;
  float charWidth;
  float charWidthWithoutSpacing, charHeightWithoutSpacing;
  int numberOfLines;

  CGColorRef colorTable[16];
  CGColorRef defaultFGColor;
  CGColorRef defaultBGColor;
  CGColorRef defaultBoldColor;
  CGColorRef defaultCursorColor;
  CGColorRef cursorTextColor;

  // transparency
  float transparency;
  BOOL useTransparency;

  // data source
  VT100Screen *dataSource;

  BOOL showCursor;
}

//+ (NSCursor *) textViewCursor;
- (id)initWithFrame: (struct CGRect) aRect;
- (void)dealloc;
- (void)drawRect:(CGRect)rect;

/*
- (void)changeFont:(id)sender;

//get/set methods
- (NSFont *)font;
- (NSFont *)nafont;
- (void) setFont:(NSFont*)aFont nafont:(NSFont*)naFont;
- (BOOL) antiAlias;
- (void) setAntiAlias: (BOOL) antiAliasFlag;
- (BOOL) disableBold;
- (void) setDisableBold: (BOOL) boldFlag;
- (BOOL) blinkingCursor;
- (void) setBlinkingCursor: (BOOL) bFlag;
*/

//color stuff
- (CGColorRef) defaultFGColor;
- (CGColorRef) defaultBGColor;
- (CGColorRef) defaultBoldColor;
- (CGColorRef) colorForCode:(unsigned int) index;
- (CGColorRef) defaultCursorColor;
- (CGColorRef) cursorTextColor;
- (void) setFGColor:(CGColorRef)color;
- (void) setBGColor:(CGColorRef)color;
- (void) setBoldColor:(CGColorRef)color;
- (void) setCursorColor:(CGColorRef) color;
- (void) setCursorTextColor:(CGColorRef) color;

- (VT100Screen*) dataSource;
- (void) setDataSource: (VT100Screen*) aDataSource;

- (void) refresh;
- (void) showCursor;
- (void) hideCursor;

/*
// transparency
- (float) transparency;
- (void) setTransparency: (float) fVal;
- (BOOL) useTransparency;
- (void) setUseTransparency: (BOOL) flag;
*/

@end
