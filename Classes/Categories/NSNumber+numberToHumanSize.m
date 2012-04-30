/* Copyright (c) 2012 Chris Ledet
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is furnished to do
 * so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */


#import "NSNumber+numberToHumanSize.h"

@implementation NSNumber (numberToHumanSize)

- (double) toGigabytes
{
    return ([self doubleValue] / 1024) / 1024 / 1024.0;
}

- (double) toMegabytes
{
    return ([self doubleValue] / 1024) / 1024.0;
}

- (double) toKilobytes
{
    return [self doubleValue] / 1024.0;
}

- (NSString*) numberToHumanSize
{
    NSString* humanSize;
    double value = [self doubleValue];
    
    if (value >= GIGABYTE) {
        humanSize = [NSString stringWithFormat:@"%.2fGB", [self toGigabytes]];
    } else if (value >= MEGABYTE) {
        humanSize = [NSString stringWithFormat:@"%.2fMB", [self toMegabytes]];
    } else if (value >= KILOBYTE) {
        humanSize = [NSString stringWithFormat:@"%.2fKB", [self toKilobytes]];
    } else {
        humanSize = [NSString stringWithFormat:@"%.2f Bytes", value];
    }
    
    return humanSize;
}

@end