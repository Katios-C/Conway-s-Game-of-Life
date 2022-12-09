
import SwiftUI

struct ContentView: View {
    
    @State private var automaton = CellularAutomaton(width: 100, height: 100)
    @State private var isResetting = false
    @State private var task: Task<Void, Error>?
    private var isRunning: Bool { self.task != nil }
    
    func start() {
        self.task = Task.detached(priority: .userInitiated) {
            while true {
                try await Task.sleep(nanoseconds: 250_000_000)
                self.automaton.next()
            }
        }
    }
    
    func stop() {
        self.task?.cancel()
        self.task = nil
    }
    
    
    var body: some View {
        
        VStack(spacing: 5) {
            Text(self.automaton.time.description)
                .padding(20)
            
            VStack(spacing: 1) {
                ForEach(0..<self.automaton.height, id: \.self) { y in
                    HStack(spacing: 1) {
                        ForEach(0..<self.automaton.width, id: \.self) { x in
                            Rectangle()
                                .fill(self.automaton[x, y] ? .black : .white)
                                .scaledToFit()
                        }
                    }
                }
            }
            .drawingGroup()
            .onAppear {
                self.automaton.putRPentomino()
            }
            self.controls
        }
        
    }
    
    private var controls: some View {
        
        HStack {
            
            Button(!self.isRunning ? "Start" : "Stop") {
                !self.isRunning ? self.start() : self.stop()
            }
            .foregroundColor(.white)
            .padding(10)
            .background(isRunning ? Color.red : Color.blue)
            .cornerRadius(8)
            
            Button("Randomize") {
                self.automaton.clear()
                self.automaton.putRandomly()
            }
            .disabled(self.isRunning)
            .foregroundColor(.white)
            .padding(10)
            .background(Color.blue)
            .cornerRadius(8)
        }
        
    }
    
    
    
    struct CellularAutomaton {
        let width: Int
        let height: Int
        let neighborhood: Neighborhood
        private(set) var time = 0
        var map: [Bool]
        
        init(width: Int, height: Int, neighborhood: Neighborhood = .moore) {
            self.width = width
            self.height = height
            self.neighborhood = neighborhood
            self.map = .init(repeating: .init(), count: height * width)
        }
        
        mutating func clear() {
            self.time = 0
            for i in 0..<self.map.count {
                self.map[i] = .init()
            }
        }
        
        mutating func putRandomly() {
            for i in 0..<self.map.count {
                self.map[i] = .random()
            }
        }
        
        mutating func putRPentomino() {
            self[1, 0] = true
            self[2, 0] = true
            self[0, 1] = true
            self[1, 1] = true
            self[1, 2] = true
        }
        
        mutating func next() {
            self.time += 1
            self.map = .init(unsafeUninitializedCapacity: self.map.count) { buffer, initializedCount in
                for y in 0..<self.height {
                    for x in 0..<self.width {
                        let nextState: Bool
                        switch (self[x, y], self.countLiveNeighbors(x, y)) {
                        case (true, ...1): nextState = false
                        case (true, 2...3): nextState = true
                        case (true, 4...): nextState = false
                        case (true, _): preconditionFailure()
                        case (false, 3): nextState = true
                        case (false, _): nextState = false
                        }
                        buffer[y * self.width + x] = nextState
                    }
                }
                initializedCount = self.map.count
            }
        }
        
        private func countLiveNeighbors(_ x: Int, _ y: Int) -> Int {
            let prevX = (x - 1 + self.width) % self.width
            let prevY = (y - 1 + self.height) % self.height
            let nextX = (x + 1) % self.width
            let nextY = (y + 1) % self.height
            let neighbors: [Bool]
            switch self.neighborhood {
            case .vonNeumann:
                neighbors = [
                    self[x, prevY],
                    self[prevX, y],
                    self[nextX, y],
                    self[x, nextY],
                ]
            case .moore:
                neighbors = [
                    self[prevX, prevY],
                    self[x, prevY],
                    self[nextX, prevY],
                    self[prevX, y],
                    self[nextX, y],
                    self[prevX, nextY],
                    self[x, nextY],
                    self[nextX, nextY],
                ]
            }
            return neighbors.lazy.filter { $0 }.count
        }
        
        subscript(x: Int, y: Int) -> Bool {
            get { self.map[y * self.width + x] }
            set { self.map[y * self.width + x] = newValue }
        }
    }
    
    enum Neighborhood {
        case vonNeumann
        case moore
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
