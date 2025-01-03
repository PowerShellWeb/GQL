#requires -Module PSSVG

$AssetsPath = $PSScriptRoot | Split-Path | Join-Path -ChildPath "Assets"

if (-not (Test-Path $AssetsPath)) {
    New-Item -ItemType Directory -Path $AssetsPath | Out-Null
}
$myName = $MyInvocation.MyCommand.Name -replace '\.PSSVG\.ps1$'

$strokeWidth = '0.5%'
$fontName = 'Noto Sans'
foreach ($variant in '','Animated') { 
    $outputPath = if (-not $variant) {
        Join-Path $assetsPath "$myName.svg"
    } else {
        Join-Path $assetsPath "$myName-$variant.svg"
    }
    $symbolDefinition = SVG.symbol -Id 'PowerShellWeb' @(
        svg -content $(
            $fillParameters = [Ordered]@{
                Fill        = '#4488FF'
                Class       = 'foreground-fill'        
            }
        
            $strokeParameters = [Ordered]@{
                Stroke      = '#4488FF'
                Class       = 'foreground-stroke'
                StrokeWidth = $strokeWidth
            }
        
            $transparentFill = [Ordered]@{Fill='transparent'}
            $animationDuration = [Ordered]@{
                Dur = "4.2s"
                RepeatCount = "indefinite"
            }
        
            SVG.GoogleFont -FontName $fontName
        
            svg.symbol -Id psChevron -Content @(
                svg.polygon -Points (@(
                    "40,20"
                    "45,20"
                    "60,50"
                    "35,80"
                    "32.5,80"
                    "55,50"
                ) -join ' ')
            ) -ViewBox 100, 100 
        
            
        
            SVG.circle -CX 50% -Cy 50% -R 42% @transparentFill @strokeParameters -Content @(            
            )
            SVG.ellipse -Cx 50% -Cy 50% -Rx 23% -Ry 42% @transparentFill @strokeParameters  -Content @(
                if ($variant -match 'animate') {
                    svg.animate -Values '23%;16%;23%' -AttributeName rx @animationDuration
                }
            )
            SVG.ellipse -Cx 50% -Cy 50% -Rx 16% -Ry 42% @transparentFill @strokeParameters  -Content @(
                if ($variant -match 'animate') {
                    svg.animate -Values '16%;23%;16%' -AttributeName rx @animationDuration
                }
            ) -Opacity .9
            SVG.ellipse -Cx 50% -Cy 50% -Rx 15% -Ry 42% @transparentFill @strokeParameters  -Content @(
                if ($variant -match 'animate') {
                    svg.animate -Values '15%;16%;15%' -AttributeName rx @animationDuration                
                }
            ) -Opacity .8
            SVG.ellipse -Cx 50% -Cy 50% -Rx 42% -Ry 23% @transparentFill @strokeParameters  -Content @(
                if ($variant -match 'animate') {
                    svg.animate -Values '23%;16%;23%' -AttributeName ry @animationDuration
                }
            )
            SVG.ellipse -Cx 50% -Cy 50% -Rx 42% -Ry 16% @transparentFill @strokeParameters  -Content @(
                if ($variant -match 'animate') {
                    svg.animate -Values '16%;23%;16%' -AttributeName ry @animationDuration
                }
            ) -Opacity .9
            SVG.ellipse -Cx 50% -Cy 50% -Rx 42% -Ry 15% @transparentFill @strokeParameters  -Content @(
                if ($variant -match 'animate') {
                    svg.animate -Values '15%;16%;15%' -AttributeName ry @animationDuration
                }
            ) -Opacity .8
            
            svg.use -Href '#psChevron' -Y 39% @fillParameters -Height 23%
        ) -ViewBox 0, 0, 200, 200 -TransformOrigin 50%, 50%
    )

    $shapeSplat = [Ordered]@{
        CenterX=(1080/2)
        CenterY=(1080/2)
        Radius=((1080 * .15) /2)
    }


    svg -Content @(
        SVG.GoogleFont -FontName $fontName
        $symbolDefinition
        SVG.Use -Href '#PowerShellWeb' -Height 60% -Width 60% -X 20% -Y 20%
        # svg.use -Href '#psChevron' -Y 75.75% -X 14% @fillParameters -Height 7.5%
        # svg.use -Href '#psChevron' -Y 75.75% -X 14% @fillParameters -Height 7.5% -TransformOrigin '50% 50%' -Transform 'scale(-1 1)'
        SVG.Hexagon @shapeSplat -StrokeWidth .5em -Stroke '#4488FF' -Fill 'transparent' -Class 'foreground-stroke' 
        # SVG.ConvexPolygon -SideCount 3 @shapeSplat -Rotate 180 -StrokeWidth .25em -Stroke '#4488FF' -Fill 'transparent' -Class 'foreground-stroke'  -Opacity .3
        SVG.text -X 50% -Y 80% -TextAnchor middle -FontFamily $fontName -Style "font-family:`"$fontName`",sans-serif" -FontSize 4.2em -Fill '#4488FF' -Content 'GQL' -Class 'foreground-fill'  -DominantBaseline middle
    ) -OutputPath $outputPath -ViewBox 0, 0, 1080, 1080
}
