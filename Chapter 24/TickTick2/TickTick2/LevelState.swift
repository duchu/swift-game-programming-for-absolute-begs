import SpriteKit

class LevelState : SKNode {
    
    var waterDrops = [WaterDrop]()
    
    var tileField = TileField()
    var world = SKNode()
    
    // initializers
    init(fileReader: FileReader) {
        super.init()
        self.name = "main"
        self.addChild(world)
        
        let _ = fileReader.nextLine() // for now, we do not use help
        let sizeArr = fileReader.nextLine().componentsSeparatedByString(" ")
        let width = Int(sizeArr[0])!, height = Int(sizeArr[1])!
        let _ = Int(fileReader.nextLine())! // for now, we do not use the time for each level
        
        tileField = TileField(rows: height, columns: width, cellWidth: 72, cellHeight: 55)
        tileField.name = "tileField"
        world.addChild(tileField)
        
        let backgrounds = SKNode()
        world.addChild(backgrounds)
        
        // sky
        let background = SKSpriteNode(imageNamed: "spr_sky")
        background.xScale = CGFloat(tileField.layout.width) / background.size.width
        background.yScale = CGFloat(tileField.layout.height) / background.size.height
        background.zPosition = Layer.Background
        backgrounds.addChild(background)
        
        var lines: [String] = []
        for _ in 0..<height {
            var newLine = fileReader.nextLine()
            while newLine.characters.count < width {
                newLine += " "
            }
            lines.append(newLine)
        }
        
        
        for i in 0..<height {
            let currLine = lines[height-1-i]
            var j = 0
            for c in currLine.characters {
                tileField.layout.add(loadTile(c, x: j, y: i))
                j += 1
            }
        }
        
        let walkLeftButton = Button(imageNamed:"spr_button_left")
        walkLeftButton.name = "button_walkleft"
        walkLeftButton.position = GameScreen.instance.bottomLeft + walkLeftButton.center + CGPoint(x: 10, y: 10)
        walkLeftButton.zPosition = Layer.Overlay1
        self.addChild(walkLeftButton)
        let walkRightButton = Button(imageNamed:"spr_button_right")
        walkRightButton.name = "button_walkright"
        walkRightButton.position = walkLeftButton.position
        walkRightButton.position.x += walkRightButton.size.width + 10
        walkRightButton.zPosition = Layer.Overlay1
        self.addChild(walkRightButton)
        let jumpButton = Button(imageNamed:"spr_button_jump")
        jumpButton.name = "button_jump"
        jumpButton.position = GameScreen.instance.bottomRight + jumpButton.center - CGPoint(x: jumpButton.size.width + 10, y: -10)
        jumpButton.zPosition = Layer.Overlay1
        self.addChild(jumpButton)
        
        self.reset()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadTile(c: Character, x: Int, y: Int) -> SKNode {
        switch c {
            case "-":
                return loadBasicTile("spr_platform", tileType: TileType.Platform)
            case "+":
                return loadBasicTile("spr_platform_hot", tileType: TileType.Platform, hot: true)
            case "@":
                return loadBasicTile("spr_platform_ice", tileType: TileType.Platform, ice: true)
            case "#":
                return loadBasicTile("spr_wall", tileType: TileType.Wall)
            case "^":
                return loadBasicTile("spr_wall_hot", tileType: TileType.Wall, hot: true)
            case "*":
                return loadBasicTile("spr_wall_ice", tileType: TileType.Wall, ice: true)
            case "W":
                return loadWaterTile(x, y: y)
            case "X":
                return loadEndTile(x, y: y)
            case "1":
                return loadStartTile(x, y: y)
            default:
                return Tile()
        }
    }

    func loadBasicTile(imageNamed : String, tileType: TileType, hot: Bool = false, ice: Bool = false) -> SKNode {
        let t = Tile(imageNamed: imageNamed, type: tileType)
        t.hot = hot
        t.ice = ice
        t.zPosition = Layer.Scene
        return t
    }
    
    func loadWaterTile(x: Int, y: Int) -> SKNode {
        let w = WaterDrop()
        w.position = tileField.layout.toPosition(x, row: y)
        w.position.y += 10
        w.zPosition = Layer.Scene1
        world.addChild(w)
        self.waterDrops.append(w)
        return Tile()
    }

    func loadStartTile(x: Int, y: Int) -> SKNode {
        var startPosition = tileField.layout.toPosition(x, row: y)
        startPosition.y -= CGFloat(tileField.layout.cellHeight / 2)
        let player = Player(startPos: startPosition)
        player.name = "player"
        player.zPosition = Layer.Scene1
        world.addChild(player)
        return Tile()
    }
    
    func loadEndTile(x: Int, y: Int) -> SKNode {
        let exit = SKSpriteNode(imageNamed: "spr_goal")
        exit.name = "exit"
        exit.anchorPoint = CGPoint(x: 0.5, y: 0)
        exit.position = tileField.layout.toPosition(x, row: y)
        exit.position.y -= CGFloat(tileField.layout.cellHeight / 2)
        exit.zPosition = Layer.Scene1
        world.addChild(exit)
        return Tile()
    }
}